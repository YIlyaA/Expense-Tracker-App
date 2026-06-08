import 'package:drift/native.dart';
import 'package:expenses_tracker/core/database/app_database.dart';
import 'package:expenses_tracker/core/database/daos/settings_dao.dart';
import 'package:expenses_tracker/core/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsDao dao;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SettingsDao(db);
    repo = SettingsRepository(settingsDao: dao);
  });

  tearDown(() => db.close());

  test('getSettings returns defaults on first call', () async {
    final settings = await repo.getSettings();
    expect(settings.preferredLanguage, 'en');
    expect(settings.preferredCurrency, 'PLN');
  });

  test('updateLanguage changes language and marks dirty', () async {
    await repo.updateLanguage('pl');

    final settings = await repo.getSettings();
    expect(settings.preferredLanguage, 'pl');

    final row = await dao.getSettings();
    expect(row.isDirty, true);
  });

  test('updateCurrency changes currency and marks dirty', () async {
    await repo.updateCurrency('USD');

    final settings = await repo.getSettings();
    expect(settings.preferredCurrency, 'USD');

    final row = await dao.getSettings();
    expect(row.isDirty, true);
  });

  test('updateMonthlyBudget persists value', () async {
    await repo.updateMonthlyBudget(1500);

    final stream = repo.watchMonthlyBudget();
    final budget = await stream.first;
    expect(budget, 1500);
  });
}
