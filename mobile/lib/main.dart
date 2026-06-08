import 'package:expenses_tracker/app/app.dart';
import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/di/service_locator.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sl = ServiceLocator.instance;
  await sl.init();

  final controller = AppController(
    transactionRepository: sl.transactionRepository,
    categoryRepository: sl.categoryRepository,
    settingsRepository: sl.settingsRepository,
    authRepository: sl.authRepository,
    syncService: sl.syncService,
    connectivityService: sl.connectivityService,
    insightsApiService: sl.insightsApiService,
  );
  await controller.init();

  runApp(ExpenseTrackerApp(controller: controller));
}
