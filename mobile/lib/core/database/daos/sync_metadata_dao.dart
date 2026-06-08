import 'package:drift/drift.dart';

import '../app_database.dart';

part 'sync_metadata_dao.g.dart';

@DriftAccessor(tables: [SyncMetadata])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin {
  SyncMetadataDao(super.db);

  Future<DateTime?> getLastSyncTimestamp() async {
    final row = await (select(syncMetadata)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    return row?.lastSyncTimestamp;
  }

  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    final exists = await (select(syncMetadata)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();

    if (exists != null) {
      await (update(syncMetadata)..where((s) => s.id.equals(1)))
          .write(SyncMetadataCompanion(lastSyncTimestamp: Value(timestamp)));
    } else {
      await into(syncMetadata).insert(
        SyncMetadataCompanion.insert(lastSyncTimestamp: Value(timestamp)),
      );
    }
  }

  Future<void> clear() => delete(syncMetadata).go();
}
