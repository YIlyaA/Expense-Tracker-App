import '../database/app_database.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/sync_metadata_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../network/api_client.dart';
import '../network/services/auth_api_service.dart';
import '../network/services/categories_api_service.dart';
import '../network/services/insights_api_service.dart';
import '../network/services/ml_api_service.dart';
import '../network/services/settings_api_service.dart';
import '../network/services/sync_api_service.dart';
import '../network/services/transactions_api_service.dart';
import '../network/token_storage.dart';
import '../repositories/auth_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/transaction_repository.dart';
import '../sync/connectivity_service.dart';
import '../sync/sync_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final instance = ServiceLocator._();

  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AppDatabase database;

  late final TransactionDao transactionDao;
  late final CategoryDao categoryDao;
  late final SettingsDao settingsDao;
  late final SyncMetadataDao syncMetadataDao;

  late final AuthApiService authApiService;
  late final TransactionsApiService transactionsApiService;
  late final CategoriesApiService categoriesApiService;
  late final SettingsApiService settingsApiService;
  late final InsightsApiService insightsApiService;
  late final MlApiService mlApiService;
  late final SyncApiService syncApiService;

  late final AuthRepository authRepository;
  late final TransactionRepository transactionRepository;
  late final CategoryRepository categoryRepository;
  late final SettingsRepository settingsRepository;

  late final ConnectivityService connectivityService;
  late final SyncService syncService;

  Future<void> init() async {
    tokenStorage = TokenStorage();
    apiClient = ApiClient(tokenStorage: tokenStorage);
    database = AppDatabase();

    transactionDao = TransactionDao(database);
    categoryDao = CategoryDao(database);
    settingsDao = SettingsDao(database);
    syncMetadataDao = SyncMetadataDao(database);

    authApiService = AuthApiService(apiClient: apiClient);
    transactionsApiService = TransactionsApiService(apiClient: apiClient);
    categoriesApiService = CategoriesApiService(apiClient: apiClient);
    settingsApiService = SettingsApiService(apiClient: apiClient);
    insightsApiService = InsightsApiService(apiClient: apiClient);
    mlApiService = MlApiService(apiClient: apiClient);
    syncApiService = SyncApiService(apiClient: apiClient);

    authRepository = AuthRepository(
      authApiService: authApiService,
      tokenStorage: tokenStorage,
    );
    transactionRepository = TransactionRepository(
      transactionDao: transactionDao,
    );
    categoryRepository = CategoryRepository(
      categoryDao: categoryDao,
      apiService: categoriesApiService,
    );
    settingsRepository = SettingsRepository(
      settingsDao: settingsDao,
    );

    connectivityService = ConnectivityService();

    syncService = SyncService(
      syncApiService: syncApiService,
      transactionDao: transactionDao,
      categoryDao: categoryDao,
      settingsDao: settingsDao,
      syncMetadataDao: syncMetadataDao,
      connectivityService: connectivityService,
    );
  }
}
