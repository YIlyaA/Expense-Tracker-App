// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Tracker wydatków';

  @override
  String get welcomeTitle => 'Inteligentny tracker wydatków';

  @override
  String get welcomeSubtitle =>
      'Śledź wydatki bez wysiłku. Kategoryzuj automatycznie. Wydawaj mądrzej.';

  @override
  String get logIn => 'Zaloguj się';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get welcomeBack => 'Witaj ponownie';

  @override
  String get signInToAccount => 'Zaloguj się do swojego konta';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Hasło';

  @override
  String get passwordHint => 'hasło';

  @override
  String get dontHaveAccount => 'Nie masz konta?';

  @override
  String get signUp => 'Zarejestruj się';

  @override
  String get createAccountTitle => 'Utwórz konto';

  @override
  String get startTrackingSubtitle => 'Zacznij śledzić swoje wydatki';

  @override
  String get confirmPassword => 'Potwierdź hasło';

  @override
  String get alreadyHaveAccount => 'Masz już konto?';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get myBalance => 'Moje saldo';

  @override
  String get spentLabel => 'Wydane';

  @override
  String get remainingLabel => 'Pozostało';

  @override
  String get quickAddHint => 'Szybki wpis: \"pizza 35 zł\"';

  @override
  String get spentThisMonth => 'Wydano w tym miesiącu';

  @override
  String get recentLabel => 'Ostatnie';

  @override
  String get seeAll => 'Zobacz wszystko';

  @override
  String get setBalanceTitle => 'Ustaw saldo';

  @override
  String totalBalanceLabel(String currency) {
    return 'Łączne saldo ($currency)';
  }

  @override
  String get setBalanceAction => 'Ustaw saldo';

  @override
  String get addExpenseTitle => 'Dodaj wydatek';

  @override
  String amountLabel(String currency) {
    return 'Kwota ($currency)';
  }

  @override
  String get descriptionLabel => 'Opis';

  @override
  String get descriptionHint => 'np. \"Pizza z przyjaciółmi\"';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get showAllCategories => 'Pokaż wszystkie kategorie';

  @override
  String get saveExpense => 'Zapisz wydatek';

  @override
  String get selectCategoryTitle => 'Wybierz kategorię';

  @override
  String get transactionsTitle => 'Transakcje';

  @override
  String get filterByCategory => 'Filtruj według kategorii';

  @override
  String get expensesLabel => 'WYDATKI';

  @override
  String get countLabel => 'LICZBA';

  @override
  String get noTransactionsYet => 'Brak transakcji dla tego miesiąca.';

  @override
  String get statisticsTitle => 'Statystyki';

  @override
  String get spendingByCategory => 'Wydatki według kategorii';

  @override
  String get monthlyTrend => 'Trend miesięczny';

  @override
  String get insightsTitle => 'Wnioski';

  @override
  String get insightsSubtitle => 'Analiza wydatków wspierana AI';

  @override
  String get insightsEmpty =>
      'Za mało danych - dodaj kilka transakcji, aby zobaczyć wnioski.';

  @override
  String get insightsLoadError =>
      'Nie udało się załadować wniosków. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get insightsRetry => 'Spróbuj ponownie';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get languageLabel => 'Język';

  @override
  String get currencyLabel => 'Waluta';

  @override
  String get logOutLabel => 'Wyloguj się';

  @override
  String get categoryFood => 'Jedzenie';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryPhone => 'Telefon';

  @override
  String get categorySport => 'Sport';

  @override
  String get categoryHousehold => 'Dom';

  @override
  String get categoryHealth => 'Zdrowie';

  @override
  String get categoryDocuments => 'Dokumenty';

  @override
  String get categoryClothes => 'Ubrania / rzeczy';

  @override
  String get categorySubscriptions => 'Subskrypcje';

  @override
  String get categoryTopUps => 'Doładowania';

  @override
  String get categoryOther => 'Inne';

  @override
  String get currencyPln => 'PLN (zł)';

  @override
  String get currencyUsd => 'USD (\$)';

  @override
  String get currencyEur => 'EUR (€)';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageRussian => 'Rosyjski';

  @override
  String get homeTab => 'Start';

  @override
  String get historyTab => 'Historia';

  @override
  String get statsTab => 'Statystyki';

  @override
  String get insightsTab => 'Wnioski';

  @override
  String get settingsTab => 'Ustawienia';

  @override
  String get mockExpenseSaved => 'Wydatek zapisany.';

  @override
  String get expenseUpdated => 'Zmiany zapisane.';

  @override
  String get expenseDeleted => 'Wydatek usunięty.';

  @override
  String get expenseSaveFailed => 'Nie udało się zapisać. Spróbuj ponownie.';

  @override
  String get expenseDeleteFailed => 'Nie udało się usunąć. Spróbuj ponownie.';

  @override
  String get editExpenseTitle => 'Edytuj wydatek';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get saving => 'Zapisywanie…';

  @override
  String get editAction => 'Edytuj';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get cancelAction => 'Anuluj';

  @override
  String get clearFilters => 'Wyczyść';

  @override
  String get offlineMode => 'Tryb offline';

  @override
  String get retryAction => 'Spróbuj ponownie';

  @override
  String get noInternetConnection => 'Brak połączenia z internetem';

  @override
  String get settingsSaveFailed =>
      'Nie udało się zapisać ustawienia. Spróbuj ponownie.';

  @override
  String get suggestedCategoryLabel => 'Sugerowana kategoria';

  @override
  String get suggestionApply => 'Zastosuj';

  @override
  String get deleteConfirmTitle => 'Usunąć ten wydatek?';

  @override
  String get deleteConfirmBody => 'Tej operacji nie można cofnąć.';

  @override
  String get validationRequired => 'To pole jest wymagane.';

  @override
  String get validationInvalidEmail => 'Wpisz poprawny adres e-mail.';

  @override
  String get validationPasswordShort => 'Hasło musi mieć co najmniej 6 znaków.';

  @override
  String get validationPasswordsMismatch => 'Hasła nie są takie same.';

  @override
  String get validationAmountRequired => 'Podaj kwotę większą niż 0.';
}
