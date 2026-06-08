import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_formatters.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/features/add_expense/presentation/widgets/category_picker_dialog.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_surface.dart';
import 'package:expenses_tracker/shared/widgets/transaction_actions_sheet.dart';
import 'package:expenses_tracker/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, this.initialCategoryFilter});

  final CategoryType? initialCategoryFilter;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime? _selectedMonth;
  DateTimeRange? _customRange;
  CategoryType? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _categoryFilter = widget.initialCategoryFilter;
  }

  @override
  void didUpdateWidget(covariant TransactionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryFilter != null &&
        widget.initialCategoryFilter != oldWidget.initialCategoryFilter) {
      _categoryFilter = widget.initialCategoryFilter;
    }
  }

  bool get _hasCustomRange => _customRange != null;
  bool get _hasCategoryFilter => _categoryFilter != null;
  bool get _hasAnyFilter => _hasCustomRange || _hasCategoryFilter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final locale = Localizations.localeOf(context);
    final currencySymbol = controller.currency.symbol;

    final effectiveMonth = _selectedMonth ?? controller.referenceMonth;

    final periodStart = _customRange?.start ??
        DateTime(effectiveMonth.year, effectiveMonth.month, 1);
    final periodEnd = _customRange?.end ??
        DateTime(effectiveMonth.year, effectiveMonth.month + 1, 0);

    final periodTransactions = controller.transactions
        .where((t) =>
            !t.date.isBefore(_dayFloor(periodStart)) &&
            !t.date.isAfter(_dayCeil(periodEnd)))
        .toList();

    final filtered = _hasCategoryFilter
        ? periodTransactions
            .where((t) => t.category == _categoryFilter)
            .toList()
        : periodTransactions;

    final groupedTransactions = _groupTransactions(filtered);
    final expenses =
        filtered.fold<double>(0, (sum, entry) => sum + entry.amount);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: controller.syncNow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.transactionsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_hasAnyFilter)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(context.l10n.clearFilters),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!_hasCustomRange)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.availableMonths
                        .map((month) {
                          final selected = month.year == effectiveMonth.year &&
                              month.month == effectiveMonth.month;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _MonthChip(
                              label: AppFormatters.monthChip(month, locale),
                              selected: selected,
                              onTap: () =>
                                  setState(() => _selectedMonth = month),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              if (!_hasCustomRange) const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DateBox(
                      label: AppFormatters.dayDate(
                        periodStart,
                        locale,
                        padDay: true,
                      ),
                      onTap: _pickDateRange,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_right_alt,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: _DateBox(
                      label:
                          AppFormatters.dayDate(periodEnd, locale, padDay: true),
                      onTap: _pickDateRange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickCategoryFilter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: _hasCategoryFilter
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: _hasCategoryFilter
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _hasCategoryFilter
                              ? _categoryFilter!.label(context.l10n)
                              : context.l10n.filterByCategory,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: _hasCategoryFilter
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ),
                      if (_hasCategoryFilter)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _categoryFilter = null),
                          icon: const Icon(Icons.close,
                              size: 18, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      color: AppColors.danger,
                      icon: Icons.remove_circle_outline,
                      label: context.l10n.expensesLabel,
                      value: AppFormatters.money(
                        expenses,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      color: AppColors.textSecondary,
                      icon: Icons.tag_outlined,
                      label: context.l10n.countLabel,
                      value: '${filtered.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                AppSurfaceCard(
                  child: Text(
                    context.l10n.noTransactionsYet,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else
                ...groupedTransactions.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppFormatters.dayDate(entry.key, locale),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        ...entry.value.map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => showTransactionActions(
                                    context, transaction),
                                child: AppSurfaceCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: TransactionTile(
                                    entry: transaction,
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: initial,
    );
    if (picked != null) {
      setState(() => _customRange = picked);
    }
  }

  Future<void> _pickCategoryFilter() async {
    final initial = _categoryFilter ?? CategoryType.food;
    final picked = await showDialog<CategoryType>(
      context: context,
      builder: (_) => CategoryPickerDialog(selectedCategory: initial),
    );
    if (picked != null) {
      setState(() => _categoryFilter = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _customRange = null;
      _categoryFilter = null;
    });
  }

  Map<DateTime, List<TransactionEntry>> _groupTransactions(
    List<TransactionEntry> transactions,
  ) {
    final grouped = <DateTime, List<TransactionEntry>>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      grouped.putIfAbsent(day, () => []).add(transaction);
    }
    return grouped;
  }

  static DateTime _dayFloor(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _dayCeil(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
