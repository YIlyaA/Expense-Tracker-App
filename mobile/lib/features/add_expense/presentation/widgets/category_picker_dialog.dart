import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_dialog_shell.dart';
import 'package:expenses_tracker/shared/widgets/category_tile.dart';
import 'package:flutter/material.dart';

class CategoryPickerDialog extends StatelessWidget {
  const CategoryPickerDialog({super.key, required this.selectedCategory});

  final CategoryType selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      title: context.l10n.selectCategoryTitle,
      onClose: () => Navigator.of(context).pop(),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
        children: CategoryType.values
            .map(
              (category) => CategoryTile(
                category: category,
                selected: category == selectedCategory,
                onTap: () => Navigator.of(context).pop(category),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
