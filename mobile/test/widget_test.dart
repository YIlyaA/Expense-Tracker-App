import 'package:expenses_tracker/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  testWidgets('app boots on the welcome screen', (tester) async {
    final controller = createTestController();
    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Smart Expense Tracker'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('welcome to login navigation works', (tester) async {
    final controller = createTestController();
    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('app renders in Polish when locale changes', (tester) async {
    final controller = createTestController()
      ..setLocale(const Locale('pl'));

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Inteligentny tracker wydatków'), findsOneWidget);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });
}
