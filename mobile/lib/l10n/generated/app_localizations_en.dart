// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get welcomeTitle => 'Smart Expense Tracker';

  @override
  String get welcomeSubtitle =>
      'Track expenses effortlessly. Categorize automatically. Spend smarter.';

  @override
  String get logIn => 'Log In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get startTrackingSubtitle => 'Start tracking your expenses';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get myBalance => 'My Balance';

  @override
  String get spentLabel => 'Spent';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get quickAddHint => 'Quick add: \"pizza 35 zł\"';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String get recentLabel => 'Recent';

  @override
  String get seeAll => 'See all';

  @override
  String get setBalanceTitle => 'Set Balance';

  @override
  String totalBalanceLabel(String currency) {
    return 'Total balance ($currency)';
  }

  @override
  String get setBalanceAction => 'Set Balance';

  @override
  String get addExpenseTitle => 'Add Expense';

  @override
  String amountLabel(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'e.g. \"Pizza with friends\"';

  @override
  String get categoryLabel => 'Category';

  @override
  String get showAllCategories => 'Show all categories';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get selectCategoryTitle => 'Select Category';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get expensesLabel => 'EXPENSES';

  @override
  String get countLabel => 'COUNT';

  @override
  String get noTransactionsYet => 'No transactions for this month yet.';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get monthlyTrend => 'Monthly Trend';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsSubtitle => 'AI-powered spending analysis';

  @override
  String get insightsEmpty =>
      'Not enough data yet - add a few transactions to start seeing insights.';

  @override
  String get insightsLoadError =>
      'Couldn\'t load insights. Check your connection and try again.';

  @override
  String get insightsRetry => 'Retry';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get logOutLabel => 'Log Out';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryPhone => 'Phone';

  @override
  String get categorySport => 'Sport';

  @override
  String get categoryHousehold => 'Household';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryClothes => 'Clothes / Items';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryTopUps => 'Top-ups';

  @override
  String get categoryOther => 'Other';

  @override
  String get currencyPln => 'PLN (zł)';

  @override
  String get currencyUsd => 'USD (\$)';

  @override
  String get currencyEur => 'EUR (€)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageRussian => 'Russian';

  @override
  String get homeTab => 'Home';

  @override
  String get historyTab => 'History';

  @override
  String get statsTab => 'Stats';

  @override
  String get insightsTab => 'Insights';

  @override
  String get settingsTab => 'Settings';

  @override
  String get mockExpenseSaved => 'Expense saved.';

  @override
  String get expenseUpdated => 'Changes saved.';

  @override
  String get expenseDeleted => 'Expense deleted.';

  @override
  String get expenseSaveFailed => 'Could not save expense. Try again.';

  @override
  String get expenseDeleteFailed => 'Could not delete expense. Try again.';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saving => 'Saving…';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get clearFilters => 'Clear';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get retryAction => 'Retry';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get settingsSaveFailed => 'Couldn\'t save setting. Try again.';

  @override
  String get suggestedCategoryLabel => 'Suggested category';

  @override
  String get suggestionApply => 'Apply';

  @override
  String get deleteConfirmTitle => 'Delete this expense?';

  @override
  String get deleteConfirmBody => 'This can\'t be undone.';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationInvalidEmail => 'Enter a valid email address.';

  @override
  String get validationPasswordShort =>
      'Password must have at least 6 characters.';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match.';

  @override
  String get validationAmountRequired => 'Enter an amount greater than 0.';
}
