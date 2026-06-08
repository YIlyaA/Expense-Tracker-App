import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/features/add_expense/presentation/screens/add_expense_screen.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool?> showTransactionActions(
  BuildContext context,
  TransactionEntry entry,
) {
  if (entry.localId == null) {
    // Synthetic preview rows can't be edited/deleted.
    return Future.value(false);
  }
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionActionsSheet(entry: entry),
  );
}

class _TransactionActionsSheet extends StatelessWidget {
  const _TransactionActionsSheet({required this.entry});

  final TransactionEntry entry;

  Future<void> _onEdit(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop(true);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(existing: entry),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _onDelete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = context.read<AppController>();
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await controller.deleteExpense(entry.localId!);
      navigator.pop(true);
      messenger.showSnackBar(SnackBar(content: Text(l10n.expenseDeleted)));
    } catch (_) {
      navigator.pop(false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.expenseDeleteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.textPrimary),
              title: Text(context.l10n.editAction),
              onTap: () => _onEdit(context),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.danger),
              title: Text(
                context.l10n.deleteAction,
                style: const TextStyle(color: AppColors.danger),
              ),
              onTap: () => _onDelete(context),
            ),
            const SizedBox(height: 6),
            ListTile(
              title: Center(
                child: Text(
                  context.l10n.cancelAction,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
