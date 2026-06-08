import 'package:expenses_tracker/app/navigation/app_router.dart';
import 'package:expenses_tracker/app/navigation/app_routes.dart';
import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppController>.value(
      value: controller,
      child: Selector<AppController, Locale>(
        selector: (_, c) => c.locale,
        builder: (context, locale, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: AppController.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.light(),
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: controller.isAuthenticated
                ? AppRoutes.shell
                : AppRoutes.welcome,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
