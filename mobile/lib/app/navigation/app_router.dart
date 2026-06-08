import 'package:expenses_tracker/app/navigation/app_routes.dart';
import 'package:expenses_tracker/features/add_expense/presentation/screens/add_expense_screen.dart';
import 'package:expenses_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expenses_tracker/features/auth/presentation/screens/register_screen.dart';
import 'package:expenses_tracker/features/auth/presentation/screens/welcome_screen.dart';
import 'package:expenses_tracker/features/navigation/presentation/screens/main_shell_screen.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case AppRoutes.shell:
        final args = settings.arguments is MainShellArguments
            ? settings.arguments! as MainShellArguments
            : const MainShellArguments();
        return MaterialPageRoute<void>(
          builder: (_) => MainShellScreen(
            initialTab: args.initialTab,
            transactionsCategoryFilter: args.transactionsCategoryFilter,
          ),
          settings: settings,
        );
      case AppRoutes.addExpense:
        final args = settings.arguments is AddExpenseArguments
            ? settings.arguments! as AddExpenseArguments
            : const AddExpenseArguments();
        return MaterialPageRoute<void>(
          builder: (_) =>
              AddExpenseScreen(initialDescription: args.initialDescription),
          settings: settings,
        );
      case AppRoutes.welcome:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
    }
  }
}
