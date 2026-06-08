import 'package:drift/drift.dart';

import '../app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [LocalUserSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<LocalUserSetting> getSettings() async {
    final result = await (select(localUserSettings)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    if (result != null) return result;

    await into(localUserSettings).insert(
      LocalUserSettingsCompanion.insert(updatedAt: DateTime.now()),
    );
    return (select(localUserSettings)..where((s) => s.id.equals(1)))
        .getSingle();
  }

  Stream<LocalUserSetting> watchSettings() =>
      (select(localUserSettings)..where((s) => s.id.equals(1)))
          .watchSingle();

  Future<void> updateSettings(LocalUserSettingsCompanion entry) =>
      (update(localUserSettings)..where((s) => s.id.equals(1))).write(entry);

  Future<void> markDirty() =>
      (update(localUserSettings)..where((s) => s.id.equals(1)))
          .write(const LocalUserSettingsCompanion(isDirty: Value(true)));

  Future<void> clearDirty() =>
      (update(localUserSettings)..where((s) => s.id.equals(1)))
          .write(const LocalUserSettingsCompanion(isDirty: Value(false)));

  Future<void> resetToDefaults() =>
      (delete(localUserSettings)..where((s) => s.id.equals(1))).go();
}
