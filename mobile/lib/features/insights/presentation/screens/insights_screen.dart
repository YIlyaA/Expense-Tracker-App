import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/shared/models/api_models.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, this.onOpenTransactionsForCategory});

  final ValueChanged<CategoryType>? onOpenTransactionsForCategory;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final cards = controller.insightCards;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: controller.loadInsights,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.insightsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.insightsSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (controller.insightsLoading && cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.insightsError != null && cards.isEmpty)
                _InsightsError(
                  message: controller.insightsError!,
                  onRetry: controller.loadInsights,
                )
              else if (cards.isEmpty)
                const _InsightsEmpty()
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _InsightCardTile(
                      card: card,
                      onOpenCategory: widget.onOpenTransactionsForCategory,
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

class _InsightCardTile extends StatelessWidget {
  const _InsightCardTile({required this.card, this.onOpenCategory});

  final InsightCard card;
  final ValueChanged<CategoryType>? onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final visuals = _visualsFor(card);
    final relatedCode = card.relatedCategoryCode;
    final canDrillIn = onOpenCategory != null && relatedCode != null;

    final tile = AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(
            icon: visuals.icon,
            backgroundColor: visuals.background,
            foregroundColor: visuals.foreground,
            size: 44,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  card.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (canDrillIn)
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
        ],
      ),
    );

    if (!canDrillIn) return tile;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onOpenCategory!(CategoryType.fromCode(relatedCode)),
        child: tile,
      ),
    );
  }
}

class _InsightsEmpty extends StatelessWidget {
  const _InsightsEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.insights_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              context.l10n.insightsEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsError extends StatelessWidget {
  const _InsightsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              context.l10n.insightsLoadError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l10n.insightsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightVisuals {
  const _InsightVisuals({
    required this.icon,
    required this.background,
    required this.foreground,
  });
  final IconData icon;
  final Color background;
  final Color foreground;
}

_InsightVisuals _visualsFor(InsightCard card) {
  IconData icon;
  switch (card.code) {
    case 'month_over_month_increase':
      icon = Icons.trending_up;
    case 'month_over_month_decrease':
      icon = Icons.trending_down;
    case 'top_category_current_month':
      icon = Icons.local_fire_department_outlined;
    case 'weekend_spending_pattern':
      icon = Icons.weekend_outlined;
    case 'weekday_spending_pattern':
      icon = Icons.business_center_outlined;
    case 'most_frequent_category':
      icon = Icons.repeat;
    case 'recurring_category_signal':
      icon = Icons.autorenew;
    case 'not_enough_data':
      icon = Icons.hourglass_empty;
    default:
      icon = Icons.lightbulb_outline;
  }

  Color background;
  Color foreground;
  switch (card.severity) {
    case 'positive':
      foreground = AppColors.success;
      background = AppColors.success.withValues(alpha: 0.12);
    case 'warning':
      foreground = AppColors.danger;
      background = AppColors.danger.withValues(alpha: 0.12);
    case 'info':
    default:
      foreground = AppColors.transport;
      background = AppColors.transport.withValues(alpha: 0.12);
  }

  return _InsightVisuals(
      icon: icon, background: background, foreground: foreground);
}
