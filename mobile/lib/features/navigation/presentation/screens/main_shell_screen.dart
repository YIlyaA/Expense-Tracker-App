import 'package:expenses_tracker/app/navigation/app_routes.dart';
import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/sync/sync_types.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:expenses_tracker/features/insights/presentation/screens/insights_screen.dart';
import 'package:expenses_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:expenses_tracker/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:expenses_tracker/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialTab = AppTab.dashboard,
    this.transactionsCategoryFilter,
  });

  final AppTab initialTab;
  final CategoryType? transactionsCategoryFilter;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late AppTab _currentTab = widget.initialTab;
  late CategoryType? _txCategoryFilter = widget.transactionsCategoryFilter;
  bool _redirectedOnAuthLoss = false;
  AppController? _watchedController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AppController>();
    if (_watchedController != controller) {
      _watchedController?.removeListener(_handleAuthChange);
      controller.addListener(_handleAuthChange);
      _watchedController = controller;
    }
  }

  @override
  void dispose() {
    _watchedController?.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    if (_redirectedOnAuthLoss) return;
    final controller = _watchedController;
    if (controller == null || controller.isAuthenticated) return;
    _redirectedOnAuthLoss = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.welcome,
        (route) => false,
      );
    });
  }

  void _openTransactionsForCategory(CategoryType category) {
    setState(() {
      _currentTab = AppTab.transactions;
      _txCategoryFilter = category;
    });
  }

  Future<void> _openAddExpense([String? initialDescription]) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.addExpense,
      arguments: AddExpenseArguments(initialDescription: initialDescription),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    await context.read<AppController>().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (!controller.isOnline) const _OfflineBanner(),
          if (controller.syncStatus == SyncStatus.syncing)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: IndexedStack(
              index: _currentTab.index,
              children: [
                DashboardScreen(
                  onAddExpenseRequested: _openAddExpense,
                  onOpenTransactions: () =>
                      setState(() => _currentTab = AppTab.transactions),
                  onOpenTransactionsForCategory:
                      _openTransactionsForCategory,
                ),
                TransactionsScreen(initialCategoryFilter: _txCategoryFilter),
                StatisticsScreen(
                  onOpenTransactionsForCategory:
                      _openTransactionsForCategory,
                ),
                InsightsScreen(
                  onOpenTransactionsForCategory:
                      _openTransactionsForCategory,
                ),
                SettingsScreen(onLogOut: _logout),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentTab == AppTab.dashboard
          ? FloatingActionButton(
              key: const ValueKey('dashboard_fab'),
              onPressed: () => _openAddExpense(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textSecondary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                context.l10n.offlineMode,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<AppController>().syncNow(),
                child: Text(
                  context.l10n.retryAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
