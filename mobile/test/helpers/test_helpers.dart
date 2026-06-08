import 'package:drift/native.dart';
import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/database/app_database.dart';
import 'package:expenses_tracker/core/database/daos/category_dao.dart';
import 'package:expenses_tracker/core/database/daos/settings_dao.dart';
import 'package:expenses_tracker/core/database/daos/sync_metadata_dao.dart';
import 'package:expenses_tracker/core/database/daos/transaction_dao.dart';
import 'package:expenses_tracker/core/network/services/auth_api_service.dart';
import 'package:expenses_tracker/core/network/services/categories_api_service.dart';
import 'package:expenses_tracker/core/network/services/insights_api_service.dart';
import 'package:expenses_tracker/core/network/services/sync_api_service.dart';
import 'package:expenses_tracker/core/network/token_storage.dart';
import 'package:expenses_tracker/core/repositories/auth_repository.dart';
import 'package:expenses_tracker/core/repositories/category_repository.dart';
import 'package:expenses_tracker/core/repositories/settings_repository.dart';
import 'package:expenses_tracker/core/repositories/transaction_repository.dart';
import 'package:expenses_tracker/core/sync/connectivity_service.dart';
import 'package:expenses_tracker/core/sync/sync_service.dart';
import 'package:expenses_tracker/core/network/api_client.dart';

AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

AppController createTestController() {
  final db = createTestDatabase();
  final tokenStorage = TokenStorage.inMemory();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  final transactionDao = TransactionDao(db);
  final categoryDao = CategoryDao(db);
  final settingsDao = SettingsDao(db);
  final syncMetadataDao = SyncMetadataDao(db);

  final authApiService = AuthApiService(apiClient: apiClient);
  final categoriesApiService = CategoriesApiService(apiClient: apiClient);
  final insightsApiService = InsightsApiService(apiClient: apiClient);
  final syncApiService = SyncApiService(apiClient: apiClient);

  return AppController(
    transactionRepository: TransactionRepository(
      transactionDao: transactionDao,
    ),
    categoryRepository: CategoryRepository(
      categoryDao: categoryDao,
      apiService: categoriesApiService,
    ),
    settingsRepository: SettingsRepository(settingsDao: settingsDao),
    authRepository: AuthRepository(
      authApiService: authApiService,
      tokenStorage: tokenStorage,
    ),
    syncService: SyncService(
      syncApiService: syncApiService,
      transactionDao: transactionDao,
      categoryDao: categoryDao,
      settingsDao: settingsDao,
      syncMetadataDao: syncMetadataDao,
      connectivityService: ConnectivityService(),
    ),
    connectivityService: ConnectivityService(),
    insightsApiService: insightsApiService,
  );
}
