import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_formatters.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/features/dashboard/presentation/widgets/set_balance_dialog.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_surface.dart';
import 'package:expenses_tracker/shared/widgets/transaction_actions_sheet.dart';
import 'package:expenses_tracker/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onAddExpenseRequested,
    required this.onOpenTransactions,
    required this.onOpenTransactionsForCategory,
  });

  final Future<void> Function([String? initialDescription])
  onAddExpenseRequested;
  final VoidCallback onOpenTransactions;
  final ValueChanged<CategoryType> onOpenTransactionsForCategory;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showBalanceDialog(AppController controller) {
    showDialog<void>(
      context: context,
      builder: (context) => SetBalanceDialog(
        currencySymbol: controller.currency.symbol,
        onSave: controller.setBalance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final currencySymbol = controller.currency.symbol;
    final topChips = controller.currentMonthCategoryTotals.entries
        .take(3)
        .map((e) => _DashboardChipData(
              amount: e.value.round(),
              category: e.key,
            ))
        .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.dashboardTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSurfaceCard(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.myBalance,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 28),
                                children: [
                                  TextSpan(
                                    text: controller.balance.toStringAsFixed(2),
                                  ),
                                  TextSpan(
                                    text: currencySymbol,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoundIconButton(
                        icon: Icons.account_balance_wallet_outlined,
                        backgroundColor: AppColors.otherBg,
                        foregroundColor: AppColors.textSecondary,
                        onPressed: () => _showBalanceDialog(controller),
                      ),
                      const SizedBox(width: 10),
                      _RoundIconButton(
                        icon: Icons.arrow_circle_up_outlined,
                        backgroundColor: AppColors.sportBg,
                        foregroundColor: AppColors.success,
                        onPressed: () => widget.onAddExpenseRequested(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _DashboardStatPill(
                          label: context.l10n.spentLabel,
                          amount: AppFormatters.money(
                            controller.spentThisMonth,
                            symbol: currencySymbol,
                          ),
                          backgroundColor: AppColors.healthBg,
                          foregroundColor: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardStatPill(
                          label: context.l10n.remainingLabel,
                          amount: AppFormatters.money(
                            controller.remainingThisMonth,
                            symbol: currencySymbol,
                          ),
                          backgroundColor: AppColors.sportBg,
                          foregroundColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.spentThisMonth,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: Colors.white, fontSize: 36),
                      children: [
                        TextSpan(
                          text: controller.spentThisMonth.toStringAsFixed(2),
                        ),
                        TextSpan(
                          text: ' $currencySymbol',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topChips
                        .map(
                          (chip) => _DashboardAmountChip(
                            data: chip,
                            symbol: currencySymbol,
                            onTap: () => widget
                                .onOpenTransactionsForCategory(chip.category),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.recentLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: widget.onOpenTransactions,
                  child: Text(context.l10n.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.recentTransactions.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => showTransactionActions(context, entry),
                    child: AppSurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: TransactionTile(
                        entry: entry,
                        currencySymbol: currencySymbol,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatPill extends StatelessWidget {
  const _DashboardStatPill({
    required this.label,
    required this.amount,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final String amount;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: foregroundColor),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: foregroundColor, size: 20),
      ),
    );
  }
}

class _DashboardChipData {
  const _DashboardChipData({required this.amount, required this.category});

  final int amount;
  final CategoryType category;
}

class _DashboardAmountChip extends StatelessWidget {
  const _DashboardAmountChip({
    required this.data,
    required this.symbol,
    this.onTap,
  });

  final _DashboardChipData data;
  final String symbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.category.icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                AppFormatters.money(
                  data.amount.toDouble(),
                  symbol: symbol,
                  trimDecimals: true,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
