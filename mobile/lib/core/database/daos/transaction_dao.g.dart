// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalCategoriesTable get localCategories => attachedDatabase.localCategories;
  $LocalTransactionsTable get localTransactions =>
      attachedDatabase.localTransactions;
  TransactionDaoManager get managers => TransactionDaoManager(this);
}

class TransactionDaoManager {
  final _$TransactionDaoMixin _db;
  TransactionDaoManager(this._db);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.localCategories,
      );
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(
        _db.attachedDatabase,
        _db.localTransactions,
      );
}
