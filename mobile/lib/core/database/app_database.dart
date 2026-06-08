import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';


class LocalCategories extends Table {
  TextColumn get code => text()();
  TextColumn get defaultLabel => text()();
  TextColumn get label => text()();
  TextColumn get iconKey => text()();
  TextColumn get color => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {code};
}

class LocalTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get clientId => text()();
  TextColumn get categoryCode =>
      text().references(LocalCategories, #code)();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get originalAmount => real()();
  TextColumn get originalCurrency => text()();
  RealColumn get baseAmount => real()();
  TextColumn get baseCurrency => text()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get pendingAction => text().nullable()();
}

class LocalUserSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get preferredLanguage =>
      text().withDefault(const Constant('en'))();
  TextColumn get preferredCurrency =>
      text().withDefault(const Constant('PLN'))();
  RealColumn get monthlyBudget =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadata extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastSyncTimestamp => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}


@DriftDatabase(
  tables: [LocalCategories, LocalTransactions, LocalUserSettings, SyncMetadata],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(localUserSettings, localUserSettings.monthlyBudget);
          }
          if (from < 3) {
            await m.alterTable(TableMigration(localUserSettings));
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'expenses.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
