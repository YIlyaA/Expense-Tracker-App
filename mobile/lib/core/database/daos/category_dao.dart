import 'package:drift/drift.dart';

import '../app_database.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [LocalCategories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<LocalCategory>> getActiveCategories() =>
      (select(localCategories)
            ..where((c) => c.isActive.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();

  Stream<List<LocalCategory>> watchActiveCategories() =>
      (select(localCategories)
            ..where((c) => c.isActive.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .watch();

  Future<void> upsertCategories(List<LocalCategoriesCompanion> categories) {
    return batch((b) {
      b.insertAllOnConflictUpdate(localCategories, categories);
    });
  }
}
