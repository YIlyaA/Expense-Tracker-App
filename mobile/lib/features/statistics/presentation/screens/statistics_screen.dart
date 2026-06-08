import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/features/statistics/presentation/widgets/chart_widgets.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _StatsPeriod { oneMonth, threeMonths, sixMonths, oneYear }

extension _StatsPeriodX on _StatsPeriod {
  int get months => switch (this) {
        _StatsPeriod.oneMonth => 1,
        _StatsPeriod.threeMonths => 3,
        _StatsPeriod.sixMonths => 6,
        _StatsPeriod.oneYear => 12,
      };

  String get label => switch (this) {
        _StatsPeriod.oneMonth => '1M',
        _StatsPeriod.threeMonths => '3M',
        _StatsPeriod.sixMonths => '6M',
        _StatsPeriod.oneYear => '1Y',
      };
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.onOpenTransactionsForCategory});

  final ValueChanged<CategoryType>? onOpenTransactionsForCategory;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  _StatsPeriod _period = _StatsPeriod.oneMonth;

  ({DateTime start, DateTime end}) _rangeFor(_StatsPeriod period) {
    final now = DateTime.now();
    if (period == _StatsPeriod.oneMonth) {
      return (start: DateTime(now.year, now.month, 1), end: now);
    }
    final start = DateTime(now.year, now.month - (period.months - 1), 1);
    return (start: start, end: now);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final range = _rangeFor(_period);
    final categoryTotals =
        controller.categoryTotalsForRange(range.start, range.end);
    final total = categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final sections = total > 0
        ? categoryTotals.entries
            .map(
              (entry) => ChartSection(
                color: entry.key.color,
                value: entry.value,
                label: entry.key.label(context.l10n),
                percentage: ((entry.value / total) * 100).round(),
                category: entry.key,
              ),
            )
            .toList(growable: false)
        : const <ChartSection>[];

    final trendPoints = controller.monthlyTrendForLast(_period.months);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.statisticsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _PeriodSelector(
              current: _period,
              onChanged: (p) => setState(() => _period = p),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.spendingByCategory,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 18),
                  if (sections.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          context.l10n.noTransactionsYet,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    )
                  else ...[
                    Center(
                      child: SpendingDonutChart(
                        total: total,
                        sections: sections,
                        symbol: controller.currency.symbol,
                        onSectionTap: widget.onOpenTransactionsForCategory == null
                            ? null
                            : (s) {
                                final c = s.category;
                                if (c != null) {
                                  widget.onOpenTransactionsForCategory!(c);
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 14,
                      runSpacing: 10,
                      children: sections
                          .map(
                            (section) => _LegendItem(
                              color: section.color,
                              label:
                                  '${section.label} (${section.percentage}%)',
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.monthlyTrend,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 18),
                  MonthlyTrendChart(
                    points: trendPoints,
                    locale: Localizations.localeOf(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.current, required this.onChanged});

  final _StatsPeriod current;
  final ValueChanged<_StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _StatsPeriod.values
            .map(
              (p) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: p == current
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        p.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: p == current
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
