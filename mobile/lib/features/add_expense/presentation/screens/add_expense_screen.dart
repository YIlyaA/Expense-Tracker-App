import 'dart:async';

import 'package:expenses_tracker/app/state/app_controller.dart';
import 'package:expenses_tracker/core/di/service_locator.dart';
import 'package:expenses_tracker/core/network/services/ml_api_service.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/utils/app_formatters.dart';
import 'package:expenses_tracker/core/utils/app_localization_x.dart';
import 'package:expenses_tracker/features/add_expense/presentation/widgets/category_picker_dialog.dart';
import 'package:expenses_tracker/shared/models/api_models.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:expenses_tracker/shared/widgets/app_buttons.dart';
import 'package:expenses_tracker/shared/widgets/category_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.initialDescription,
    this.existing,
  });

  final String? initialDescription;
  final TransactionEntry? existing;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late CategoryType _selectedCategory;
  late DateTime _selectedDate;
  bool _saving = false;

  bool _userPickedCategory = false;

  CategoryPrediction? _lastPrediction;
  Timer? _predictionDebounce;

  bool get _isEditing => widget.existing != null;
  MlApiService get _ml => ServiceLocator.instance.mlApiService;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(
      text: existing?.title ?? widget.initialDescription ?? '',
    );
    _selectedCategory = existing?.category ?? CategoryType.food;
    _selectedDate = existing?.date ?? DateTime.now();
    _userPickedCategory = existing != null;

    _descriptionController.addListener(_onDescriptionChanged);

    if (_descriptionController.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestPrediction());
    }
  }

  @override
  void dispose() {
    _predictionDebounce?.cancel();
    _descriptionController.removeListener(_onDescriptionChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onDescriptionChanged() {
    _predictionDebounce?.cancel();
    final text = _descriptionController.text.trim();
    if (text.length < 3) {
      if (_lastPrediction != null && mounted) {
        setState(() => _lastPrediction = null);
      }
      return;
    }
    _predictionDebounce = Timer(
      const Duration(milliseconds: 450),
      _requestPrediction,
    );
  }

  Future<void> _requestPrediction() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) return;
    try {
      final raw = await _ml.predictCategory(inputText: text);
      if (!mounted) return;
      final prediction = CategoryPrediction.fromJson(raw);
      setState(() {
        _lastPrediction = prediction;
        if (!_userPickedCategory &&
            prediction.hasConfidentPrediction &&
            prediction.predictedCategoryCode != null) {
          final suggested =
              CategoryType.fromCode(prediction.predictedCategoryCode!);
          _selectedCategory = suggested;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Category prediction failed: $e');
      }
    }
  }

  void _selectCategoryManually(CategoryType category) {
    setState(() {
      _selectedCategory = category;
      _userPickedCategory = true;
    });
  }

  Future<void> _showCategoryDialog() async {
    final selected = await showDialog<CategoryType>(
      context: context,
      builder: (_) => CategoryPickerDialog(selectedCategory: _selectedCategory),
    );

    if (selected != null) {
      _selectCategoryManually(selected);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (_saving) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.validationAmountRequired)),
      );
      return;
    }

    final description = _descriptionController.text.trim().isEmpty
        ? _selectedCategory.label(context.l10n)
        : _descriptionController.text.trim();

    setState(() => _saving = true);
    try {
      final controller = context.read<AppController>();
      final existing = widget.existing;
      if (existing != null && existing.localId != null) {
        await controller.updateExpense(
          localId: existing.localId!,
          amount: amount,
          description: description,
          category: _selectedCategory,
          transactionDate: _selectedDate,
        );
      } else {
        await controller.addExpense(
          amount: amount,
          description: description,
          category: _selectedCategory,
          transactionDate: _selectedDate,
        );
      }

      final prediction = _lastPrediction;
      if (!_isEditing && description.isNotEmpty) {
        unawaited(_sendFeedback(
          inputText: description,
          selectedCategory: _selectedCategory,
          prediction: prediction,
        ));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? context.l10n.expenseUpdated
              : context.l10n.mockExpenseSaved),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.expenseSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendFeedback({
    required String inputText,
    required CategoryType selectedCategory,
    required CategoryPrediction? prediction,
  }) async {
    try {
      await _ml.sendFeedback(
        inputText: inputText,
        selectedCategoryCode: selectedCategory.toCode(),
        predictedCategoryCode: prediction?.predictedCategoryCode,
        predictedConfidence: prediction?.confidence,
        predictedStatus: prediction?.status,
        predictionStrategy: prediction?.strategy,
        classifierVersion: prediction?.classifierVersion,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ML feedback send failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final quickCategories = controller.quickCategories;
    final locale = Localizations.localeOf(context);
    final prediction = _lastPrediction;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _isEditing
                        ? context.l10n.editExpenseTitle
                        : context.l10n.addExpenseTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Center(
                child: Column(
                  children: [
                    Text(
                      context.l10n.amountLabel(controller.currency.symbol),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: 52,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 52,
                                color: AppColors.border,
                              ),
                          suffixText: controller.currency.symbol,
                          suffixStyle: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppFormatters.dayDate(_selectedDate, locale),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(Icons.expand_more,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.descriptionLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: context.l10n.descriptionHint,
                ),
              ),
              if (prediction != null &&
                  prediction.predictedCategoryCode != null &&
                  prediction.predictedCategoryCode !=
                      _selectedCategory.toCode())
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _PredictionSuggestion(
                    prediction: prediction,
                    onAccept: () => _selectCategoryManually(
                      CategoryType.fromCode(prediction.predictedCategoryCode!),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                context.l10n.categoryLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.84,
                children: quickCategories
                    .map(
                      (category) => CategoryTile(
                        category: category,
                        selected: category == _selectedCategory,
                        onTap: () => _selectCategoryManually(category),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: _showCategoryDialog,
                  child: Text(context.l10n.showAllCategories),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: _saving
                      ? context.l10n.saving
                      : (_isEditing
                          ? context.l10n.saveChanges
                          : context.l10n.saveExpense),
                  onPressed: _saving ? null : _saveExpense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PredictionSuggestion extends StatelessWidget {
  const _PredictionSuggestion({
    required this.prediction,
    required this.onAccept,
  });

  final CategoryPrediction prediction;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final code = prediction.predictedCategoryCode;
    if (code == null) return const SizedBox.shrink();
    final category = CategoryType.fromCode(code);
    final isConfident = prediction.hasConfidentPrediction;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onAccept,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: category.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConfident
                ? category.color.withValues(alpha: 0.6)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: category.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${context.l10n.suggestedCategoryLabel}: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    TextSpan(
                      text: category.label(context.l10n),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              context.l10n.suggestionApply,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
