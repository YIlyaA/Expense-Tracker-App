// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Трекер расходов';

  @override
  String get welcomeTitle => 'Умный трекер расходов';

  @override
  String get welcomeSubtitle =>
      'Отслеживайте расходы без усилий. Категоризируйте автоматически. Тратьте умнее.';

  @override
  String get logIn => 'Войти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToAccount => 'Войдите в свой аккаунт';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'пароль';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get createAccountTitle => 'Создать аккаунт';

  @override
  String get startTrackingSubtitle => 'Начните отслеживать свои расходы';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get dashboardTitle => 'Дашборд';

  @override
  String get myBalance => 'Мой баланс';

  @override
  String get spentLabel => 'Потрачено';

  @override
  String get remainingLabel => 'Осталось';

  @override
  String get quickAddHint => 'Быстро добавить: \"pizza 35 zł\"';

  @override
  String get spentThisMonth => 'Потрачено в этом месяце';

  @override
  String get recentLabel => 'Последние';

  @override
  String get seeAll => 'Смотреть все';

  @override
  String get setBalanceTitle => 'Установить баланс';

  @override
  String totalBalanceLabel(String currency) {
    return 'Общий баланс ($currency)';
  }

  @override
  String get setBalanceAction => 'Установить баланс';

  @override
  String get addExpenseTitle => 'Добавить расход';

  @override
  String amountLabel(String currency) {
    return 'Сумма ($currency)';
  }

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get descriptionHint => 'например, \"Пицца с друзьями\"';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get showAllCategories => 'Показать все категории';

  @override
  String get saveExpense => 'Сохранить расход';

  @override
  String get selectCategoryTitle => 'Выберите категорию';

  @override
  String get transactionsTitle => 'Транзакции';

  @override
  String get filterByCategory => 'Фильтр по категории';

  @override
  String get expensesLabel => 'РАСХОДЫ';

  @override
  String get countLabel => 'КОЛ-ВО';

  @override
  String get noTransactionsYet => 'За этот месяц пока нет транзакций.';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get spendingByCategory => 'Расходы по категориям';

  @override
  String get monthlyTrend => 'Месячный тренд';

  @override
  String get insightsTitle => 'Инсайты';

  @override
  String get insightsSubtitle => 'AI-анализ расходов';

  @override
  String get insightsEmpty =>
      'Недостаточно данных - добавьте несколько транзакций, чтобы увидеть инсайты.';

  @override
  String get insightsLoadError =>
      'Не удалось загрузить инсайты. Проверьте соединение и попробуйте снова.';

  @override
  String get insightsRetry => 'Повторить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageLabel => 'Язык';

  @override
  String get currencyLabel => 'Валюта';

  @override
  String get logOutLabel => 'Выйти';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryPhone => 'Телефон';

  @override
  String get categorySport => 'Спорт';

  @override
  String get categoryHousehold => 'Дом';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryDocuments => 'Документы';

  @override
  String get categoryClothes => 'Одежда / вещи';

  @override
  String get categorySubscriptions => 'Подписки';

  @override
  String get categoryTopUps => 'Пополнения';

  @override
  String get categoryOther => 'Другое';

  @override
  String get currencyPln => 'PLN (zł)';

  @override
  String get currencyUsd => 'USD (\$)';

  @override
  String get currencyEur => 'EUR (€)';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languagePolish => 'Польский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get homeTab => 'Главная';

  @override
  String get historyTab => 'История';

  @override
  String get statsTab => 'Статистика';

  @override
  String get insightsTab => 'Инсайты';

  @override
  String get settingsTab => 'Настройки';

  @override
  String get mockExpenseSaved => 'Расход сохранён.';

  @override
  String get expenseUpdated => 'Изменения сохранены.';

  @override
  String get expenseDeleted => 'Расход удалён.';

  @override
  String get expenseSaveFailed => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String get expenseDeleteFailed => 'Не удалось удалить. Попробуйте ещё раз.';

  @override
  String get editExpenseTitle => 'Изменить расход';

  @override
  String get saveChanges => 'Сохранить';

  @override
  String get saving => 'Сохранение…';

  @override
  String get editAction => 'Изменить';

  @override
  String get deleteAction => 'Удалить';

  @override
  String get cancelAction => 'Отмена';

  @override
  String get clearFilters => 'Сбросить';

  @override
  String get offlineMode => 'Нет сети';

  @override
  String get retryAction => 'Повторить';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get settingsSaveFailed =>
      'Не удалось сохранить настройку. Попробуйте ещё раз.';

  @override
  String get suggestedCategoryLabel => 'Предложенная категория';

  @override
  String get suggestionApply => 'Применить';

  @override
  String get deleteConfirmTitle => 'Удалить расход?';

  @override
  String get deleteConfirmBody => 'Это действие нельзя отменить.';

  @override
  String get validationRequired => 'Это поле обязательно.';

  @override
  String get validationInvalidEmail => 'Введите корректный email.';

  @override
  String get validationPasswordShort =>
      'Пароль должен содержать не менее 6 символов.';

  @override
  String get validationPasswordsMismatch => 'Пароли не совпадают.';

  @override
  String get validationAmountRequired => 'Введите сумму больше 0.';
}
