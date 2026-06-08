import 'package:drift/drift.dart';

import '../../shared/models/api_models.dart';
import '../database/app_database.dart';
import '../database/daos/category_dao.dart';
import '../network/services/categories_api_service.dart';

class CategoryRepository {
  CategoryRepository({
    required CategoryDao categoryDao,
    required CategoriesApiService apiService,
  })  : _dao = categoryDao,
        _api = apiService;

  final CategoryDao _dao;
  final CategoriesApiService _api;

  Stream<List<CategoryDto>> watchCategories() =>
      _dao.watchActiveCategories().map(
            (rows) => rows
                .map((r) => CategoryDto(
                      code: r.code,
                      defaultLabel: r.defaultLabel,
                      label: r.label,
                      iconKey: r.iconKey,
                      color: r.color,
                      sortOrder: r.sortOrder,
                      isActive: r.isActive,
                    ))
                .toList(),
          );

  Future<void> refreshFromServer() async {
    final rawList = await _api.getCategories();
    final dtos =
        rawList.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>)).toList();

    final companions = dtos
        .map((c) => LocalCategoriesCompanion.insert(
              code: c.code,
              defaultLabel: c.defaultLabel,
              label: c.label,
              iconKey: c.iconKey,
              color: c.color,
              sortOrder: c.sortOrder,
              isActive: Value(c.isActive),
              updatedAt: DateTime.now(),
            ))
        .toList();

    await _dao.upsertCategories(companions);
  }
}
