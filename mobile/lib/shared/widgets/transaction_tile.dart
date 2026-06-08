import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/utils/app_formatters.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_surface.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.entry,
    required this.currencySymbol,
  });

  final TransactionEntry entry;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final subtitle = entry.category.label(context.l10n);

    return Row(
      children: [
        AppIconBadge(
          icon: entry.category.icon,
          backgroundColor: entry.category.backgroundColor,
          foregroundColor: entry.category.color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          entry.isSynced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
          size: 14,
          color: entry.isSynced ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          AppFormatters.signedMoney(
            entry.amount,
            symbol: currencySymbol,
            positive: false,
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}
