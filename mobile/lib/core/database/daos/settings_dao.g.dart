// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUserSettingsTable get localUserSettings =>
      attachedDatabase.localUserSettings;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$LocalUserSettingsTableTableManager get localUserSettings =>
      $$LocalUserSettingsTableTableManager(
        _db.attachedDatabase,
        _db.localUserSettings,
      );
}
