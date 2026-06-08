import 'dart:async';

import 'package:expenses_tracker/core/network/services/insights_api_service.dart';
import 'package:expenses_tracker/core/repositories/auth_repository.dart';
import 'package:expenses_tracker/core/repositories/category_repository.dart';
import 'package:expenses_tracker/core/repositories/settings_repository.dart';
import 'package:expenses_tracker/core/repositories/transaction_repository.dart';
import 'package:expenses_tracker/core/sync/connectivity_service.dart';
import 'package:expenses_tracker/core/sync/sync_service.dart';
import 'package:expenses_tracker/core/sync/sync_types.dart';
import 'package:expenses_tracker/shared/models/api_models.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  AppController({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required SettingsRepository settingsRepository,
    required AuthRepository authRepository,
    required SyncService syncService,
    required ConnectivityService connectivityService,
    required InsightsApiService insightsApiService,
  })  : _transactionRepo = transactionRepository,
        _categoryRepo = categoryRepository,
        _settingsRepo = settingsRepository,
        _authRepo = authRepository,
        _syncService = syncService,
        _connectivity = connectivityService,
        _insightsApi = insightsApiService;

  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  final SettingsRepository _settingsRepo;
  final AuthRepository _authRepo;
  final SyncService _syncService;
  final ConnectivityService _connectivity;
  final InsightsApiService _insightsApi;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
    Locale('ru'),
  ];

  Locale _locale = const Locale('en');
  CurrencyOption _currency = CurrencyOption.pln;
  double _balance = 0;
  List<TransactionEntry> _transactions = [];
  List<CategoryDto> _categories = [];
  bool _authenticated = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  bool _isOnline = true;

  StreamSubscription<List<TransactionEntry>>? _txSub;
  StreamSubscription<List<CategoryDto>>? _catSub;
  StreamSubscription<UserSettingsDto>? _settingsSub;
  StreamSubscription<double>? _budgetSub;
  StreamSubscription<SyncStatus>? _syncStatusSub;
  StreamSubscription<bool>? _connectivitySub;

  Locale get locale => _locale;
  CurrencyOption get currency => _currency;
  double get balance => _balance;
  bool get isAuthenticated => _authenticated;
  SyncStatus get syncStatus => _syncStatus;
  bool get isOnline => _isOnline;
  List<CategoryDto> get categories => List.unmodifiable(_categories);

  List<TransactionEntry> get transactions =>
      List.unmodifiable(_sortedTransactions);

  List<InsightCard> _insightCards = const [];
  bool _insightsLoading = false;
  String? _insightsError;

  List<InsightCard> get insightCards => List.unmodifiable(_insightCards);
  bool get insightsLoading => _insightsLoading;
  String? get insightsError => _insightsError;

  Future<void> loadInsights() async {
    if (!_authenticated) return;
    _insightsLoading = true;
    _insightsError = null;
    notifyListeners();
    try {
      final raw = await _insightsApi.getInsights();
      final response = InsightsData.fromJson(raw);
      _insightCards = response.insights;
    } catch (e) {
      _insightsError = e.toString();
      if (kDebugMode) {
        debugPrint('Failed to load insights: $e');
      }
    } finally {
      _insightsLoading = false;
      notifyListeners();
    }
  }

  List<CategoryType> get quickCategories => _categories.isNotEmpty
      ? _categories
          .where((c) => c.code != 'top_ups' && c.code != 'other')
          .take(8)
          .map((c) => CategoryType.fromCode(c.code))
          .toList()
      : CategoryType.values
          .where((c) => c != CategoryType.topUps && c != CategoryType.other)
          .take(8)
          .toList();

  List<DateTime> get availableMonths {
    final months = <DateTime>{};
    for (final t in _transactions) {
      months.add(DateTime(t.date.year, t.date.month));
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    if (sorted.isEmpty) {
      final now = DateTime.now();
      sorted.add(DateTime(now.year, now.month));
    }
    return sorted;
  }

  DateTime get referenceMonth {
    if (_sortedTransactions.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    final latest = _sortedTransactions.first.date;
    return DateTime(latest.year, latest.month);
  }

  double get spentThisMonth => _sumForMonth(referenceMonth);
  int get countThisMonth => _transactionsForMonth(referenceMonth).length;
  double get remainingThisMonth => _balance - spentThisMonth;
  List<TransactionEntry> get recentTransactions =>
      _sortedTransactions.take(3).toList(growable: false);

  Map<CategoryType, double> get currentMonthCategoryTotals {
    final totals = <CategoryType, double>{};
    for (final transaction in _transactionsForMonth(referenceMonth)) {
      totals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final entry in entries) entry.key: entry.value};
  }

  List<MonthPoint> get monthlyTrend => monthlyTrendForLast(6);

  List<MonthPoint> monthlyTrendForLast(int months) {
    final now = DateTime.now();
    final result = <MonthPoint>[];
    for (var offset = months - 1; offset >= 0; offset--) {
      final m = DateTime(now.year, now.month - offset);
      result.add(MonthPoint(month: m, total: _sumForMonth(m)));
    }
    return result;
  }

  Map<CategoryType, double> categoryTotalsForRange(
    DateTime start,
    DateTime end,
  ) {
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final totals = <CategoryType, double>{};
    for (final t in _sortedTransactions.where(
      (t) =>
          !t.date.isBefore(dayStart) &&
          !t.date.isAfter(dayEnd),
    )) {
      totals.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }


  Future<void> init() async {
    _authenticated = await _authRepo.isLoggedIn();

    try {
      final settings = await _settingsRepo.getSettings();
      _applySettings(settings);
    } catch (_) {
    }

    _txSub = _transactionRepo.watchTransactions().listen((list) {
      _transactions = list;
      notifyListeners();
    });

    _catSub = _categoryRepo.watchCategories().listen((list) {
      _categories = list;
      notifyListeners();
    });

    _settingsSub = _settingsRepo.watchSettings().listen((settings) {
      _applySettings(settings);
      notifyListeners();
    });

    _budgetSub = _settingsRepo.watchMonthlyBudget().listen((budget) {
      _balance = budget;
      notifyListeners();
    });

    _connectivitySub = _connectivity.watchConnectivity().listen((online) {
      _isOnline = online;
      notifyListeners();
    });

    _syncStatusSub = _syncService.watchSyncStatus().listen((status) {
      _syncStatus = status;
      notifyListeners();
    });

    if (_authenticated) {
      unawaited(_validateSessionAndSync());
    }
  }

  Future<void> _validateSessionAndSync() async {
    final stillValid = await _authRepo.isSessionValid();
    if (!stillValid) {
      _authenticated = false;
      notifyListeners();
      await _syncService.clearLocalUserData();
      return;
    }
    unawaited(_syncService.performSync());
    _syncService.schedulePeriodic();
  }


  Future<UserProfile> login(String email, String password) async {
    final user = await _authRepo.login(email, password);
    _authenticated = true;
    notifyListeners();
    unawaited(_syncService.performSync());
    _syncService.schedulePeriodic();
    return user;
  }

  Future<UserProfile> register(
      String email, String password, String passwordConfirm) async {
    final user = await _authRepo.register(email, password, passwordConfirm);
    _authenticated = true;
    notifyListeners();
    unawaited(_syncService.performSync());
    _syncService.schedulePeriodic();
    return user;
  }

  Future<void> logout() async {
    _syncService.cancelPeriodic();
    await _syncService.clearLocalUserData();
    await _authRepo.logout();
    _authenticated = false;
    _transactions = [];
    _balance = 0;
    _insightCards = const [];
    _insightsError = null;
    notifyListeners();
  }


  Future<void> addExpense({
    required double amount,
    required String description,
    required CategoryType category,
    DateTime? transactionDate,
  }) async {
    await _transactionRepo.addTransaction(
      categoryCode: category.toCode(),
      description: description,
      originalAmount: amount,
      originalCurrency: _currency.name.toUpperCase(),
      transactionDate: transactionDate ?? DateTime.now(),
    );
    unawaited(_syncService.performSync());
  }

  Future<void> updateExpense({
    required int localId,
    required double amount,
    required String description,
    required CategoryType category,
    required DateTime transactionDate,
  }) async {
    await _transactionRepo.updateTransaction(
      localId,
      categoryCode: category.toCode(),
      description: description,
      originalAmount: amount,
      originalCurrency: _currency.name.toUpperCase(),
      transactionDate: transactionDate,
    );
    unawaited(_syncService.performSync());
  }

  Future<void> deleteExpense(int localId) async {
    await _transactionRepo.deleteTransaction(localId);
    unawaited(_syncService.performSync());
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    )) {
      return;
    }
    final previous = _locale;
    _locale = Locale(locale.languageCode);
    notifyListeners();
    try {
      await _settingsRepo.updateLanguage(locale.languageCode);
    } catch (_) {
      _locale = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setCurrency(CurrencyOption currency) async {
    final previous = _currency;
    _currency = currency;
    notifyListeners();
    try {
      await _settingsRepo.updateCurrency(currency.name.toUpperCase());
    } catch (_) {
      _currency = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setBalance(double balance) async {
    _balance = balance;
    notifyListeners();
    await _settingsRepo.updateMonthlyBudget(balance);
  }

  List<TransactionEntry> transactionsForMonth(DateTime month) {
    return List.unmodifiable(_transactionsForMonth(month));
  }

  Future<void> syncNow() => _syncService.performSync();


  void _applySettings(UserSettingsDto settings) {
    final langCode = settings.preferredLanguage;
    if (supportedLocales.any((l) => l.languageCode == langCode)) {
      _locale = Locale(langCode);
    }
    final currName = settings.preferredCurrency.toLowerCase();
    _currency = CurrencyOption.values.firstWhere(
      (c) => c.name == currName,
      orElse: () => CurrencyOption.pln,
    );
  }

  List<TransactionEntry> get _sortedTransactions {
    final items = List<TransactionEntry>.from(_transactions)
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        final aLocal = a.localId ?? -1;
        final bLocal = b.localId ?? -1;
        return bLocal.compareTo(aLocal);
      });
    return items;
  }

  List<TransactionEntry> _transactionsForMonth(DateTime month) {
    return _sortedTransactions
        .where(
          (transaction) =>
              transaction.date.year == month.year &&
              transaction.date.month == month.month,
        )
        .toList(growable: false);
  }

  double _sumForMonth(DateTime month) {
    return _transactionsForMonth(month)
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  @override
  void dispose() {
    _txSub?.cancel();
    _catSub?.cancel();
    _settingsSub?.cancel();
    _budgetSub?.cancel();
    _syncStatusSub?.cancel();
    _connectivitySub?.cancel();
    _syncService.cancelPeriodic();
    super.dispose();
  }
}
