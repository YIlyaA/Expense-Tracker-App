import 'dart:async';

import 'package:drift/drift.dart';

import '../../shared/models/api_models.dart';
import '../database/app_database.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/sync_metadata_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../network/services/sync_api_service.dart';
import 'connectivity_service.dart';
import 'sync_types.dart';

class SyncService {
  SyncService({
    required SyncApiService syncApiService,
    required TransactionDao transactionDao,
    required CategoryDao categoryDao,
    required SettingsDao settingsDao,
    required SyncMetadataDao syncMetadataDao,
    required ConnectivityService connectivityService,
  })  : _api = syncApiService,
        _transactionDao = transactionDao,
        _categoryDao = categoryDao,
        _settingsDao = settingsDao,
        _syncMetadataDao = syncMetadataDao,
        _connectivity = connectivityService;

  final SyncApiService _api;
  final TransactionDao _transactionDao;
  final CategoryDao _categoryDao;
  final SettingsDao _settingsDao;
  final SyncMetadataDao _syncMetadataDao;
  final ConnectivityService _connectivity;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Timer? _periodicTimer;

  Stream<SyncStatus> watchSyncStatus() => _statusController.stream;

  void schedulePeriodic({Duration interval = const Duration(minutes: 5)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) => performSync());
  }

  void cancelPeriodic() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<SyncResult> performSync() async {
    final online = await _connectivity.isOnline();
    if (!online) {
      _statusController.add(SyncStatus.offline);
      return SyncResult.offline;
    }

    _statusController.add(SyncStatus.syncing);

    try {
      final pushResult = await _push();
      final pullResult = await _pull();

      _statusController.add(SyncStatus.idle);
      return SyncResult(
        success: true,
        pushed: pushResult.pushed,
        pulled: pullResult.pulled,
        conflicts: pushResult.conflicts,
      );
    } catch (e) {
      _statusController.add(SyncStatus.error);
      return SyncResult(success: false, error: e.toString());
    }
  }


  Future<SyncResult> _push() async {
    final pending = await _transactionDao.getPendingChanges();
    final settings = await _settingsDao.getSettings();

    if (pending.isEmpty && !settings.isDirty) {
      return const SyncResult(success: true);
    }

    final created = <SyncPushTransactionCreate>[];
    final updated = <SyncPushTransactionUpdate>[];
    final deleted = <SyncPushTransactionDelete>[];

    final localOnlyDeleted = <int>[];

    for (final t in pending) {
      switch (t.pendingAction) {
        case 'create':
          created.add(SyncPushTransactionCreate(
            clientId: t.clientId,
            categoryCode: t.categoryCode,
            description: t.description,
            originalAmount: t.originalAmount.toString(),
            originalCurrency: t.originalCurrency,
            transactionDate: t.transactionDate,
          ));
        case 'update':
          if (t.serverId != null) {
            updated.add(SyncPushTransactionUpdate(
              id: t.serverId!,
              categoryCode: t.categoryCode,
              description: t.description,
              originalAmount: t.originalAmount.toString(),
              originalCurrency: t.originalCurrency,
              transactionDate: t.transactionDate,
              updatedAt: t.updatedAt,
            ));
          } else {
            created.add(SyncPushTransactionCreate(
              clientId: t.clientId,
              categoryCode: t.categoryCode,
              description: t.description,
              originalAmount: t.originalAmount.toString(),
              originalCurrency: t.originalCurrency,
              transactionDate: t.transactionDate,
            ));
          }
        case 'delete':
          if (t.serverId != null) {
            deleted.add(SyncPushTransactionDelete(id: t.serverId!));
          } else {
            localOnlyDeleted.add(t.id);
          }
      }
    }

    if (localOnlyDeleted.isNotEmpty) {
      await _transactionDao.deleteByLocalIds(localOnlyDeleted);
    }

    final hasTxChanges =
        created.isNotEmpty || updated.isNotEmpty || deleted.isNotEmpty;
    if (!hasTxChanges && !settings.isDirty) {
      return SyncResult(success: true, pushed: localOnlyDeleted.length);
    }

    final request = SyncPushRequest(
      transactions: SyncPushTransactions(
        created: created,
        updated: updated,
        deleted: deleted,
      ),
      settings: settings.isDirty
          ? SyncPushSettings(
              preferredLanguage: settings.preferredLanguage,
              preferredCurrency: settings.preferredCurrency,
              updatedAt: settings.updatedAt,
            )
          : null,
    );

    final raw = await _api.push(request.toJson());
    final response = SyncPushResponse.fromJson(raw);

    if (response.settings != null) {
      final s = response.settings!;
      await _settingsDao.updateSettings(LocalUserSettingsCompanion(
        preferredLanguage: Value(s.preferredLanguage),
        preferredCurrency: Value(s.preferredCurrency),
        updatedAt: Value(s.updatedAt),
        isDirty: const Value(false),
      ));
    }

    for (final mapping in response.idMappings) {
      await _transactionDao.markSynced(mapping.clientId, mapping.serverId);
    }

    for (final conflict in response.conflicts) {
      final sv = conflict.serverVersion;
      await _transactionDao.upsertFromServer(
        serverId: sv.id,
        categoryCode: sv.categoryCode,
        description: sv.description,
        originalAmount: double.parse(sv.originalAmount),
        originalCurrency: sv.originalCurrency,
        baseAmount: double.parse(sv.baseAmount),
        baseCurrency: sv.baseCurrency,
        transactionDate: sv.transactionDate,
        createdAt: sv.createdAt,
        updatedAt: sv.updatedAt,
      );
    }

    for (final d in deleted) {
      await _transactionDao.removeByServerId(d.id);
    }

    for (final t in pending.where((t) => t.pendingAction == 'update' && t.serverId != null)) {
      await _transactionDao.markSynced(t.clientId, t.serverId!);
    }

    if (settings.isDirty) {
      await _settingsDao.clearDirty();
    }

    return SyncResult(
      success: true,
      pushed: created.length + updated.length + deleted.length,
      conflicts: response.conflicts.length,
    );
  }


  Future<SyncResult> _pull() async {
    final lastSync = await _syncMetadataDao.getLastSyncTimestamp();
    final raw = await _api.pull(since: lastSync);
    final response = SyncPullResponse.fromJson(raw);

    final categoryCompanions = response.categories
        .map((c) => LocalCategoriesCompanion.insert(
              code: c.code,
              defaultLabel: c.defaultLabel,
              label: c.defaultLabel,
              iconKey: c.iconKey,
              color: c.color,
              sortOrder: c.sortOrder,
              isActive: Value(c.isActive),
              updatedAt: c.updatedAt,
            ))
        .toList();
    if (categoryCompanions.isNotEmpty) {
      await _categoryDao.upsertCategories(categoryCompanions);
    }

    for (final t in response.transactions.upserted) {
      await _transactionDao.upsertFromServer(
        serverId: t.id,
        categoryCode: t.categoryCode,
        description: t.description,
        originalAmount: double.parse(t.originalAmount),
        originalCurrency: t.originalCurrency,
        baseAmount: double.parse(t.baseAmount),
        baseCurrency: t.baseCurrency,
        transactionDate: t.transactionDate,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      );
    }

    for (final id in response.transactions.deletedIds) {
      await _transactionDao.removeByServerIdIfClean(id);
    }

    if (response.settings != null) {
      final s = response.settings!;
      await _settingsDao.updateSettings(LocalUserSettingsCompanion(
        preferredLanguage: Value(s.preferredLanguage),
        preferredCurrency: Value(s.preferredCurrency),
        updatedAt: Value(s.updatedAt),
        isDirty: const Value(false),
      ));
    }

    await _syncMetadataDao.setLastSyncTimestamp(response.serverTimestamp);

    return SyncResult(
      success: true,
      pulled: response.transactions.upserted.length +
          response.transactions.deletedIds.length +
          response.categories.length,
    );
  }

  Future<void> clearLocalUserData() async {
    await _transactionDao.deleteAll();
    await _settingsDao.resetToDefaults();
    await _syncMetadataDao.clear();
  }

  void dispose() {
    _periodicTimer?.cancel();
    _statusController.close();
  }
}
