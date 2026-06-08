import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLogOut});

  final VoidCallback onLogOut;

  Future<void> _runSafely(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.settingsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsCard(
              icon: Icons.language,
              iconColor: AppColors.textSecondary,
              iconBackground: AppColors.otherBg,
              title: context.l10n.languageLabel,
              trailing: _DropdownField<String>(
                value: controller.locale.languageCode,
                items: {
                  'en': context.l10n.languageEnglish,
                  'pl': context.l10n.languagePolish,
                  'ru': context.l10n.languageRussian,
                },
                onChanged: (value) {
                  if (value != null) {
                    _runSafely(
                      context,
                      () => context
                          .read<AppController>()
                          .setLocale(Locale(value)),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              icon: Icons.currency_exchange_outlined,
              iconColor: AppColors.textSecondary,
              iconBackground: AppColors.otherBg,
              title: context.l10n.currencyLabel,
              trailing: _DropdownField<CurrencyOption>(
                value: controller.currency,
                items: {
                  CurrencyOption.pln: CurrencyOption.pln.label(context.l10n),
                  CurrencyOption.usd: CurrencyOption.usd.label(context.l10n),
                  CurrencyOption.eur: CurrencyOption.eur.label(context.l10n),
                },
                onChanged: (value) {
                  if (value != null) {
                    _runSafely(
                      context,
                      () => context
                          .read<AppController>()
                          .setCurrency(value),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: onLogOut,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: _SettingsCard(
                icon: Icons.logout_rounded,
                iconColor: AppColors.danger,
                iconBackground: AppColors.healthBg,
                title: context.l10n.logOutLabel,
                titleColor: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.trailing,
    this.titleColor = AppColors.textPrimary,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final Widget? trailing;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          AppIconBadge(
            icon: icon,
            backgroundColor: iconBackground,
            foregroundColor: iconColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[trailing!],
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items.entries
              .map(
                (entry) => DropdownMenuItem<T>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
