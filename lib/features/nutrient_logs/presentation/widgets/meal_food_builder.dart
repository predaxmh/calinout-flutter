// A self-contained food builder used inside AddMealPage.
// Provides a FoodDraft — a plain data class representing a food
// not yet persisted (id: -1, mealId: -1).

import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_controller.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Draft model ────────────────────────────────────────────────────────────

/// Represents a food being built inside the meal form before save.
class FoodDraft {
  final FoodType foodType;
  final double weightInGrams;
  final double calories;
  final double protein;
  DateTime? consumedAt;
  int? mealId;
  final double fat;
  final double carbs;

  FoodDraft({
    required this.foodType,
    required this.weightInGrams,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.consumedAt,
    this.mealId,
  });

  /// Converts to a Food entity ready to nest inside a Meal POST.
  Food toFood({required bool isTemplate, DateTime? consumeAt}) => Food(
    id: -1,
    userId: '',
    name: '',
    foodTypeId: foodType.id,
    mealId: mealId,
    weightInGrams: weightInGrams,
    isTemplate: isTemplate,
    calories: calories,
    protein: protein,
    fat: fat,
    carbs: carbs,
    consumedAt: consumeAt ?? DateTime.now(),
    createdAt: DateTime.now(),
  );

  FoodDraft copyWithWeight(double w) {
    final ratio = w / foodType.baseWeightInGrams;
    return FoodDraft(
      foodType: foodType,
      weightInGrams: w,
      calories: _r(foodType.calories * ratio),
      protein: _r(foodType.protein * ratio),
      fat: _r(foodType.fat * ratio),
      carbs: _r(foodType.carbs * ratio),
    );
  }

  static double _r(double v) => double.parse(v.toStringAsFixed(2));
}

// ── Builder widget ─────────────────────────────────────────────────────────

/// Renders a food type search + weight field + live macro preview.
/// Calls [onAdd] with a completed [FoodDraft] when the user confirms.
class MealFoodBuilder extends ConsumerStatefulWidget {
  final bool isTemplate;
  final void Function(FoodDraft draft) onAdd;

  /// Optional label override for the confirm button.
  final String confirmLabel;

  const MealFoodBuilder({
    super.key,
    required this.isTemplate,
    required this.onAdd,
    this.confirmLabel = 'Add to Meal',
  });

  @override
  ConsumerState<MealFoodBuilder> createState() => _MealFoodBuilderState();
}

class _MealFoodBuilderState extends ConsumerState<MealFoodBuilder> {
  final _weightController = TextEditingController();
  final _searchController = TextEditingController();
  final _weightKey = GlobalKey<FormFieldState>();
  final _dropdownScrollController = ScrollController();

  FoodType? _selectedType;
  bool _showDropdown = false;

  double _calories = 0, _protein = 0, _fat = 0, _carbs = 0;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_recalc);
    _dropdownScrollController.addListener(() {
      if (_dropdownScrollController.position.pixels >=
          _dropdownScrollController.position.maxScrollExtent * 0.9) {
        ref.read(foodTypeControllerProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _searchController.dispose();
    _dropdownScrollController.dispose();
    super.dispose();
  }

  void _recalc() {
    final ft = _selectedType;
    if (ft == null) return;
    final w = double.tryParse(_weightController.text) ?? 0;
    final r = w / ft.baseWeightInGrams;
    setState(() {
      _calories = _r(ft.calories * r);
      _protein = _r(ft.protein * r);
      _fat = _r(ft.fat * r);
      _carbs = _r(ft.carbs * r);
    });
  }

  static double _r(double v) => double.parse(v.toStringAsFixed(2));

  void _selectType(FoodType ft) {
    setState(() {
      _selectedType = ft;
      _showDropdown = false;
    });
    _searchController.text = ft.name;
    ref.read(foodTypeSearchQueryProvider.notifier).setQuery('');
    _recalc();
  }

  bool get _canAdd =>
      _selectedType != null &&
      (double.tryParse(_weightController.text) ?? 0) > 0;

  void _submit() {
    if (!_canAdd) return;
    final ft = _selectedType!;
    final w = double.parse(_weightController.text);
    widget.onAdd(
      FoodDraft(
        foodType: ft,
        weightInGrams: w,
        calories: _calories,
        protein: _protein,
        fat: _fat,
        carbs: _carbs,
      ),
    );
    // Reset for next entry.
    _weightController.clear();
    _searchController.clear();
    setState(() {
      _selectedType = null;
      _calories = _protein = _fat = _carbs = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _showDropdown = false);
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Food type search ───────────────────────────────────────
          _buildTypeSearch(),
          const SizedBox(height: 12),

          // ── Weight ─────────────────────────────────────────────────
          TextFormField(
            key: _weightKey,
            controller: _weightController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.textFieldTextStyle.copyWith(
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Weight (g)',
              hintText: '150',
              prefixIcon: Icon(Icons.scale, color: AppColors.secondary),
              suffixText: 'g',
              labelStyle: AppTextStyles.textFieldLableStyle.copyWith(
                fontSize: 14,
                letterSpacing: 1,
              ),
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 12),

          // ── Live macro preview ─────────────────────────────────────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _canAdd ? 1.0 : 0.35,
            child: Row(
              children: [
                _MiniMacroChip('Cal', _calories, 'kcal', Colors.orange),
                const SizedBox(width: 6),
                _MiniMacroChip('P', _protein, 'g', Colors.blue),
                const SizedBox(width: 6),
                _MiniMacroChip('F', _fat, 'g', Colors.amber.shade700),
                const SizedBox(width: 6),
                _MiniMacroChip('C', _carbs, 'g', Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Add button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _canAdd
                    ? AppColors.secondary
                    : AppColors.grey.withValues(alpha: 0.3),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                widget.confirmLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: _canAdd ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSearch() {
    ref.listen(foodTypeSearchQueryProvider, (prev, next) {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchController,
          readOnly: _selectedType != null,
          style: AppTextStyles.textFieldTextStyle.copyWith(
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            labelText: 'Food Type',
            hintText: 'Search food types…',
            prefixIcon: Icon(Icons.search, color: AppColors.secondary),
            suffixIcon: _selectedType != null
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.grey.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(foodTypeSearchQueryProvider.notifier)
                          .setQuery('');
                      setState(() {
                        _selectedType = null;
                        _showDropdown = false;
                        _calories = _protein = _fat = _carbs = 0;
                      });
                    },
                  )
                : null,
            labelStyle: AppTextStyles.textFieldLableStyle.copyWith(
              fontSize: 14,
              letterSpacing: 1,
            ),
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
            filled: true,
            fillColor: _selectedType != null
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _selectedType != null
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.3),
                width: _selectedType != null ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (val) {
            ref.read(foodTypeSearchQueryProvider.notifier).setQuery(val);
            setState(() => _showDropdown = true);
          },
          onTap: () {
            if (_selectedType == null) {
              setState(() => _showDropdown = true);
            }
          },
        ),
        if (_showDropdown) _buildDropdown(),
      ],
    );
  }

  Widget _buildDropdown() {
    final asyncState = ref.watch(foodTypeControllerProvider);
    final isFetchingMore = ref.watch(foodTypeIsFetchingMoreProvider);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: asyncState.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(err.toString(), style: TextStyle(color: AppColors.error)),
        ),
        data: (state) {
          final items = state?.items ?? [];
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No food types found.'),
            );
          }
          return ListView.separated(
            controller: _dropdownScrollController,
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemCount: items.length,

            separatorBuilder: (_, i) {
              if (isFetchingMore && i == items.length - 1) {
                return const SizedBox.shrink();
              }

              return Divider(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.1),
              );
            },
            itemBuilder: (_, i) {
              if (isFetchingMore && i == items.length - 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return InkWell(
                onTap: () => _selectType(items[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'per ${items[i].baseWeightInGrams.toStringAsFixed(0)}g  ·  '
                              '${items[i].calories.toStringAsFixed(0)} kcal',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _PillTag('P', items[i].protein, Colors.blue),
                      const SizedBox(width: 4),
                      _PillTag('F', items[i].fat, Colors.amber.shade700),
                      const SizedBox(width: 4),
                      _PillTag('C', items[i].carbs, Colors.green),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────

class _MiniMacroChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MiniMacroChip(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              '$label ($unit)',
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _PillTag(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label${value.toStringAsFixed(0)}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
