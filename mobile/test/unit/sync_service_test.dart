import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:expenses_tracker/core/database/app_database.dart';
import 'package:expenses_tracker/core/database/daos/category_dao.dart';
import 'package:expenses_tracker/core/database/daos/settings_dao.dart';
import 'package:expenses_tracker/core/database/daos/sync_metadata_dao.dart';
import 'package:expenses_tracker/core/database/daos/transaction_dao.dart';
import 'package:expenses_tracker/core/sync/sync_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionDao transactionDao;
  late CategoryDao categoryDao;
  late SettingsDao settingsDao;
  late SyncMetadataDao syncMetadataDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transactionDao = TransactionDao(db);
    categoryDao = CategoryDao(db);
    settingsDao = SettingsDao(db);
    syncMetadataDao = SyncMetadataDao(db);
  });

  tearDown(() => db.close());

  group('TransactionDao', () {
    test('getPendingChanges returns only pending items', () async {
      await transactionDao.insertTransaction(
        LocalTransactionsCompanion.insert(
          clientId: 'uuid-1',
          categoryCode: 'food',
          originalAmount: 10.0,
          originalCurrency: 'PLN',
          baseAmount: 10.0,
          baseCurrency: 'PLN',
          transactionDate: DateTime(2026, 3, 1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: const Value(false),
          pendingAction: const Value('create'),
        ),
      );
      await transactionDao.insertTransaction(
        LocalTransactionsCompanion.insert(
          clientId: 'uuid-2',
          categoryCode: 'food',
          originalAmount: 20.0,
          originalCurrency: 'PLN',
          baseAmount: 20.0,
          baseCurrency: 'PLN',
          transactionDate: DateTime(2026, 3, 2),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: const Value(true),
          pendingAction: const Value(null),
        ),
      );

      final pending = await transactionDao.getPendingChanges();
      expect(pending, hasLength(1));
      expect(pending.first.clientId, 'uuid-1');
    });

    test('markSynced sets serverId and clears pendingAction', () async {
      await transactionDao.insertTransaction(
        LocalTransactionsCompanion.insert(
          clientId: 'uuid-sync',
          categoryCode: 'food',
          originalAmount: 15.0,
          originalCurrency: 'PLN',
          baseAmount: 15.0,
          baseCurrency: 'PLN',
          transactionDate: DateTime(2026, 3, 5),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: const Value(false),
          pendingAction: const Value('create'),
        ),
      );

      await transactionDao.markSynced('uuid-sync', 42);

      final all = await transactionDao.getAllTransactions();
      expect(all, hasLength(1));
      expect(all.first.serverId, 42);
      expect(all.first.isSynced, true);
      expect(all.first.pendingAction, isNull);
    });

    test('upsertFromServer inserts new and updates existing', () async {
      // Insert new
      await transactionDao.upsertFromServer(
        serverId: 100,
        categoryCode: 'transport',
        description: 'Taxi',
        originalAmount: 30.0,
        originalCurrency: 'PLN',
        baseAmount: 30.0,
        baseCurrency: 'PLN',
        transactionDate: DateTime(2026, 3, 10),
        createdAt: DateTime(2026, 3, 10),
        updatedAt: DateTime(2026, 3, 10),
      );

      var all = await transactionDao.getAllTransactions();
      expect(all, hasLength(1));
      expect(all.first.description, 'Taxi');

      // Update existing
      await transactionDao.upsertFromServer(
        serverId: 100,
        categoryCode: 'transport',
        description: 'Taxi updated',
        originalAmount: 35.0,
        originalCurrency: 'PLN',
        baseAmount: 35.0,
        baseCurrency: 'PLN',
        transactionDate: DateTime(2026, 3, 10),
        createdAt: DateTime(2026, 3, 10),
        updatedAt: DateTime(2026, 3, 11),
      );

      all = await transactionDao.getAllTransactions();
      expect(all, hasLength(1));
      expect(all.first.description, 'Taxi updated');
      expect(all.first.originalAmount, 35.0);
    });

    test('removeByServerId deletes the transaction', () async {
      await transactionDao.upsertFromServer(
        serverId: 200,
        categoryCode: 'food',
        description: 'To delete',
        originalAmount: 10.0,
        originalCurrency: 'PLN',
        baseAmount: 10.0,
        baseCurrency: 'PLN',
        transactionDate: DateTime(2026, 3, 1),
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );

      await transactionDao.removeByServerId(200);

      final all = await transactionDao.getAllTransactions();
      expect(all, isEmpty);
    });
  });

  group('CategoryDao', () {
    test('upsertCategories inserts and updates', () async {
      await categoryDao.upsertCategories([
        LocalCategoriesCompanion.insert(
          code: 'food',
          defaultLabel: 'Food',
          label: 'Food',
          iconKey: 'restaurant',
          color: '#FF0000',
          sortOrder: 1,
          updatedAt: DateTime(2026, 1, 1),
        ),
      ]);

      var cats = await categoryDao.getActiveCategories();
      expect(cats, hasLength(1));
      expect(cats.first.defaultLabel, 'Food');

      // Update
      await categoryDao.upsertCategories([
        LocalCategoriesCompanion.insert(
          code: 'food',
          defaultLabel: 'Food & Drinks',
          label: 'Food & Drinks',
          iconKey: 'restaurant',
          color: '#FF0000',
          sortOrder: 1,
          updatedAt: DateTime(2026, 1, 2),
        ),
      ]);

      cats = await categoryDao.getActiveCategories();
      expect(cats, hasLength(1));
      expect(cats.first.defaultLabel, 'Food & Drinks');
    });
  });

  group('SettingsDao', () {
    test('getSettings creates default row on first call', () async {
      final settings = await settingsDao.getSettings();
      expect(settings.preferredLanguage, 'en');
      expect(settings.preferredCurrency, 'PLN');
      expect(settings.isDirty, false);
    });

    test('markDirty and clearDirty toggle isDirty flag', () async {
      await settingsDao.getSettings(); // ensure row exists
      await settingsDao.markDirty();
      var s = await settingsDao.getSettings();
      expect(s.isDirty, true);

      await settingsDao.clearDirty();
      s = await settingsDao.getSettings();
      expect(s.isDirty, false);
    });
  });

  group('SyncMetadataDao', () {
    test('returns null when no timestamp set', () async {
      final ts = await syncMetadataDao.getLastSyncTimestamp();
      expect(ts, isNull);
    });

    test('set and get timestamp', () async {
      final now = DateTime(2026, 3, 15, 12, 0, 0);
      await syncMetadataDao.setLastSyncTimestamp(now);

      final ts = await syncMetadataDao.getLastSyncTimestamp();
      expect(ts, now);
    });

    test('overwrite timestamp', () async {
      await syncMetadataDao.setLastSyncTimestamp(DateTime(2026, 3, 1));
      await syncMetadataDao.setLastSyncTimestamp(DateTime(2026, 3, 2));

      final ts = await syncMetadataDao.getLastSyncTimestamp();
      expect(ts, DateTime(2026, 3, 2));
    });
  });

  test('SyncResult.offline has success false', () {
    expect(SyncResult.offline.success, false);
    expect(SyncResult.offline.error, 'offline');
  });
}
