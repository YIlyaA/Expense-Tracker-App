import 'dart:async';

import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/shared/widgets/app_buttons.dart';
import 'package:expenses_tracker/shared/widgets/app_dialog_shell.dart';
import 'package:flutter/material.dart';

class SetBalanceDialog extends StatefulWidget {
  const SetBalanceDialog({
    super.key,
    required this.currencySymbol,
    required this.onSave,
  });

  final String currencySymbol;
  final FutureOr<void> Function(double) onSave;

  @override
  State<SetBalanceDialog> createState() => _SetBalanceDialogState();
}

class _SetBalanceDialogState extends State<SetBalanceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.validationAmountRequired)),
      );
      return;
    }
    await widget.onSave(value);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      title: context.l10n.setBalanceTitle,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.totalBalanceLabel(widget.currencySymbol),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: context.l10n.setBalanceAction,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
