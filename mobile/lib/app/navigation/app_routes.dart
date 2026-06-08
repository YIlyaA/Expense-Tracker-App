import 'package:expenses_tracker/shared/models/app_models.dart';

abstract final class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String shell = '/app';
  static const String addExpense = '/add-expense';
}

class MainShellArguments {
  const MainShellArguments({
    this.initialTab = AppTab.dashboard,
    this.transactionsCategoryFilter,
  });

  final AppTab initialTab;

  final CategoryType? transactionsCategoryFilter;
}

class AddExpenseArguments {
  const AddExpenseArguments({this.initialDescription});

  final String? initialDescription;
}
