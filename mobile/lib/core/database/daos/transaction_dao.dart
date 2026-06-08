import 'package:drift/drift.dart';

import '../app_database.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [LocalTransactions, LocalCategories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<List<LocalTransaction>> getAllTransactions() =>
      (select(localTransactions)
            ..where((t) =>
                t.pendingAction.isNotValue('delete') |
                t.pendingAction.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  Stream<List<LocalTransaction>> watchAllTransactions() =>
      (select(localTransactions)
            ..where((t) => t.pendingAction.isNotValue('delete') | t.pendingAction.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .watch();

  Future<void> insertTransaction(LocalTransactionsCompanion entry) =>
      into(localTransactions).insert(entry);

  Future<void> updateTransaction(LocalTransactionsCompanion entry) =>
      (update(localTransactions)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  Future<void> markDeleted(int id) =>
      (update(localTransactions)..where((t) => t.id.equals(id))).write(
        const LocalTransactionsCompanion(
          pendingAction: Value('delete'),
          isSynced: Value(false),
        ),
      );

  Future<List<LocalTransaction>> getPendingChanges() =>
      (select(localTransactions)..where((t) => t.pendingAction.isNotNull()))
          .get();

  Future<void> markSynced(String clientId, int serverId) =>
      (update(localTransactions)
            ..where((t) => t.clientId.equals(clientId)))
          .write(
        LocalTransactionsCompanion(
          serverId: Value(serverId),
          isSynced: const Value(true),
          pendingAction: const Value(null),
        ),
      );

  Future<void> upsertFromServer({
    required int serverId,
    required String categoryCode,
    required String description,
    required double originalAmount,
    required String originalCurrency,
    required double baseAmount,
    required String baseCurrency,
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    final existing = await (select(localTransactions)
          ..where((t) => t.serverId.equals(serverId)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(localTransactions)
            ..where((t) => t.serverId.equals(serverId)))
          .write(LocalTransactionsCompanion(
        categoryCode: Value(categoryCode),
        description: Value(description),
        originalAmount: Value(originalAmount),
        originalCurrency: Value(originalCurrency),
        baseAmount: Value(baseAmount),
        baseCurrency: Value(baseCurrency),
        transactionDate: Value(transactionDate),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        isSynced: const Value(true),
        pendingAction: const Value(null),
      ));
    } else {
      await into(localTransactions).insert(LocalTransactionsCompanion.insert(
        serverId: Value(serverId),
        clientId: serverId.toString(),
        categoryCode: categoryCode,
        description: Value(description),
        originalAmount: originalAmount,
        originalCurrency: originalCurrency,
        baseAmount: baseAmount,
        baseCurrency: baseCurrency,
        transactionDate: transactionDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSynced: const Value(true),
        pendingAction: const Value(null),
      ));
    }
  }

  Future<void> removeByServerId(int serverId) =>
      (delete(localTransactions)..where((t) => t.serverId.equals(serverId)))
          .go();

  Future<void> removeByServerIdIfClean(int serverId) async {
    await (delete(localTransactions)
          ..where((t) =>
              t.serverId.equals(serverId) & t.pendingAction.isNull()))
        .go();
  }

  Future<void> deleteAll() => delete(localTransactions).go();

  Future<void> deleteByLocalIds(List<int> ids) =>
      (delete(localTransactions)..where((t) => t.id.isIn(ids))).go();
}
