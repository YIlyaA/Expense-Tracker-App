import 'package:drift/drift.dart';

import '../../shared/models/api_models.dart';
import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';

class SettingsRepository {
  SettingsRepository({required SettingsDao settingsDao})
      : _dao = settingsDao;

  final SettingsDao _dao;

  Stream<UserSettingsDto> watchSettings() =>
      _dao.watchSettings().map(_toDto);

  Future<UserSettingsDto> getSettings() async {
    final row = await _dao.getSettings();
    return _toDto(row);
  }

  Future<void> updateLanguage(String languageCode) async {
    await _dao.getSettings(); // ensure default row exists
    await _dao.updateSettings(LocalUserSettingsCompanion(
      preferredLanguage: Value(languageCode),
      updatedAt: Value(DateTime.now()),
    ));
    await _dao.markDirty();
  }

  Future<void> updateCurrency(String currencyCode) async {
    await _dao.getSettings(); // ensure default row exists
    await _dao.updateSettings(LocalUserSettingsCompanion(
      preferredCurrency: Value(currencyCode),
      updatedAt: Value(DateTime.now()),
    ));
    await _dao.markDirty();
  }

  Stream<double> watchMonthlyBudget() =>
      _dao.watchSettings().map((row) => row.monthlyBudget);

  Future<void> updateMonthlyBudget(double budget) async {
    await _dao.getSettings();
    await _dao.updateSettings(LocalUserSettingsCompanion(
      monthlyBudget: Value(budget),
      updatedAt: Value(DateTime.now()),
    ));
  }

  static UserSettingsDto _toDto(LocalUserSetting row) => UserSettingsDto(
        preferredLanguage: row.preferredLanguage,
        preferredCurrency: row.preferredCurrency,
      );
}
