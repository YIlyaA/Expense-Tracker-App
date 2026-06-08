import 'package:drift/native.dart';
import 'package:expenses_tracker/core/database/app_database.dart';
import 'package:expenses_tracker/core/database/daos/transaction_dao.dart';
import 'package:expenses_tracker/core/repositories/transaction_repository.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionDao dao;
  late TransactionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = TransactionDao(db);
    repo = TransactionRepository(transactionDao: dao);
  });

  tearDown(() => db.close());

  test('addTransaction inserts with pendingAction create', () async {
    await repo.addTransaction(
      categoryCode: 'food',
      description: 'Lunch',
      originalAmount: 25.50,
      originalCurrency: 'PLN',
      transactionDate: DateTime(2026, 3, 15),
    );

    final pending = await dao.getPendingChanges();
    expect(pending, hasLength(1));
    expect(pending.first.pendingAction, 'create');
    expect(pending.first.isSynced, false);
    expect(pending.first.description, 'Lunch');
    expect(pending.first.originalAmount, 25.50);
  });

  test('watchTransactions emits entries mapped to TransactionEntry', () async {
    await repo.addTransaction(
      categoryCode: 'transport',
      description: 'Bus',
      originalAmount: 5.0,
      originalCurrency: 'PLN',
      transactionDate: DateTime(2026, 3, 10),
    );

    final list = await repo.watchTransactions().first;
    expect(list, hasLength(1));
    expect(list.first.title, 'Bus');
    expect(list.first.category, CategoryType.transport);
    expect(list.first.isSynced, false);
  });

  test('deleteTransaction marks as deleted and hides from watch', () async {
    await repo.addTransaction(
      categoryCode: 'food',
      description: 'Dinner',
      originalAmount: 40.0,
      originalCurrency: 'PLN',
      transactionDate: DateTime(2026, 3, 12),
    );

    final all = await dao.getAllTransactions();
    expect(all, hasLength(1));

    await repo.deleteTransaction(all.first.id);

    final afterDelete = await dao.getAllTransactions();
    expect(afterDelete, isEmpty);

    final pending = await dao.getPendingChanges();
    expect(pending, hasLength(1));
    expect(pending.first.pendingAction, 'delete');
  });

}
