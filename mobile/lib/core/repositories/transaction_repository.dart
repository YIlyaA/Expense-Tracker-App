import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/app_models.dart';
import '../database/app_database.dart';
import '../database/daos/transaction_dao.dart';

class TransactionRepository {
  TransactionRepository({required TransactionDao transactionDao})
      : _dao = transactionDao;

  final TransactionDao _dao;
  static const _uuid = Uuid();

  Stream<List<TransactionEntry>> watchTransactions() =>
      _dao.watchAllTransactions().map(
            (rows) => rows.map(_toEntry).toList(),
          );

  Future<void> addTransaction({
    required String categoryCode,
    required String description,
    required double originalAmount,
    required String originalCurrency,
    required DateTime transactionDate,
  }) async {
    final now = DateTime.now().toUtc();
    await _dao.insertTransaction(
      LocalTransactionsCompanion.insert(
        clientId: _uuid.v4(),
        categoryCode: categoryCode,
        description: Value(description),
        originalAmount: originalAmount,
        originalCurrency: originalCurrency,
        baseAmount: originalAmount,
        baseCurrency: originalCurrency,
        transactionDate: transactionDate,
        createdAt: now,
        updatedAt: now,
        isSynced: const Value(false),
        pendingAction: const Value('create'),
      ),
    );
  }

  Future<void> updateTransaction(
    int id, {
    String? categoryCode,
    String? description,
    double? originalAmount,
    String? originalCurrency,
    DateTime? transactionDate,
  }) async {
    await _dao.updateTransaction(LocalTransactionsCompanion(
      id: Value(id),
      categoryCode: categoryCode != null ? Value(categoryCode) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      originalAmount: originalAmount != null ? Value(originalAmount) : const Value.absent(),
      originalCurrency: originalCurrency != null ? Value(originalCurrency) : const Value.absent(),
      transactionDate: transactionDate != null ? Value(transactionDate) : const Value.absent(),
      updatedAt: Value(DateTime.now().toUtc()),
      isSynced: const Value(false),
      pendingAction: const Value('update'),
    ));
  }

  Future<void> deleteTransaction(int id) => _dao.markDeleted(id);

  static TransactionEntry _toEntry(LocalTransaction row) {
    return TransactionEntry(
      id: row.clientId,
      localId: row.id,
      title: row.description,
      category: CategoryType.fromCode(row.categoryCode),
      amount: row.originalAmount,
      date: row.transactionDate,
      isSynced: row.isSynced,
    );
  }
}
