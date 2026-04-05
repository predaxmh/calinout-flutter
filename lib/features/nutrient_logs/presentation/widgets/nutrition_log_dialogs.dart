import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';

import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/food_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/meal_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

void showFoodLogDetailDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Food food,
  VoidCallback? onDeleted,
}) {
  showDialog(
    context: context,
    builder: (_) => _FoodDetailDialog(food: food, onDeleted: onDeleted),
  );
}

void showMealLogDetailDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Meal meal,
  VoidCallback? onDeleted,
}) {
  showDialog(
    context: context,
    builder: (_) => _MealDetailDialog(meal: meal, onDeleted: onDeleted),
  );
}

class _FoodDetailDialog extends ConsumerWidget {
  final Food food;
  final VoidCallback? onDeleted;

  const _FoodDetailDialog({required this.food, this.onDeleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(foodOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(NetworkErrorParser.parseError(error)),
              backgroundColor: AppColors.error,
            ),
          );
        },
        data: (_) {
          if (prev?.isLoading == true) {
            onDeleted?.call();

            Navigator.of(context).pop();
            context.showSuccess(
              food.name.isNotEmpty ? '${food.name} deleted' : 'Food deleted',
            );
          }
        },
      );
    });

    final isLoading = ref
        .watch(foodOperationsProvider)
        .maybeWhen(loading: () => true, orElse: () => false);

    final consumedLabel = DateFormat(
      'dd MMM yyyy · HH:mm',
    ).format(food.consumedAt ?? food.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DialogHeader(
                      title: food.name.isNotEmpty ? food.name : 'Food Entry',
                      subtitle:
                          '${food.weightInGrams.toStringAsFixed(0)} g  ·  $consumedLabel',
                      isTemplate: food.isTemplate,
                    ),
                    const Divider(height: 24),
                    _MacroRow(
                      label: 'Calories',
                      value: food.calories,
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _MacroRow(
                      label: 'Protein',
                      value: food.protein,
                      unit: 'g',
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _MacroRow(
                      label: 'Fat',
                      value: food.fat,
                      unit: 'g',
                      icon: Icons.water_drop,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(height: 8),
                    _MacroRow(
                      label: 'Carbs',
                      value: food.carbs,
                      unit: 'g',
                      icon: Icons.grain,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    _ActionRow(
                      isLoading: isLoading,
                      onDelete: () => _confirmDelete(
                        context: context,
                        label: food.name.isNotEmpty
                            ? '"${food.name}"'
                            : 'this food entry',
                        onConfirmed: () => ref
                            .read(foodOperationsProvider.notifier)
                            .delete(food.id),
                      ),
                      onEdit: () {
                        Navigator.of(context).pop();
                        context.push(Routes.updateFoodPage, extra: food);
                      },
                    ),
                  ],
                ),
              ),
              _CloseButton(onTap: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealDetailDialog extends ConsumerWidget {
  final Meal meal;
  final VoidCallback? onDeleted;

  const _MealDetailDialog({required this.meal, this.onDeleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(mealOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(NetworkErrorParser.parseError(error)),
              backgroundColor: AppColors.error,
            ),
          );
        },
        data: (_) {
          if (prev?.isLoading == true) {
            onDeleted?.call();
            Navigator.of(context).pop();
            context.showSuccess('"${meal.name}" deleted');
          }
        },
      );
    });

    final isLoading = ref
        .watch(mealOperationsProvider)
        .maybeWhen(loading: () => true, orElse: () => false);

    final foods = meal.foods ?? [];
    final consumedLabel = DateFormat(
      'dd MMM yyyy · HH:mm',
    ).format(meal.consumedAt ?? meal.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Scrollable content ───────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DialogHeader(
                          title: meal.name,
                          subtitle:
                              '${foods.length} food${foods.length == 1 ? '' : 's'}  ·  '
                              '${meal.totalWeight.toStringAsFixed(0)} g  ·  $consumedLabel',
                          isTemplate: meal.isTemplate,
                          titleFontSize: 22,
                        ),
                        const Divider(height: 24),

                        // ── Totals ─────────────────────────────────────────
                        Text(
                          'Meal Totals',
                          style: AppTextStyles.headerMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MacroRow(
                          label: 'Calories',
                          value: meal.totalCalories,
                          unit: 'kcal',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 8),
                        _MacroRow(
                          label: 'Protein',
                          value: meal.totalProtein,
                          unit: 'g',
                          icon: Icons.fitness_center,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 8),
                        _MacroRow(
                          label: 'Fat',
                          value: meal.totalFat,
                          unit: 'g',
                          icon: Icons.water_drop,
                          color: Colors.amber.shade700,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 8),
                        _MacroRow(
                          label: 'Carbs',
                          value: meal.totalCarbs,
                          unit: 'g',
                          icon: Icons.grain,
                          color: Colors.green,
                          fontSize: 16,
                        ),

                        // ── Food list ──────────────────────────────────────
                        if (foods.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Foods in this Meal',
                            style: AppTextStyles.headerMedium.copyWith(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _FoodItemList(foods: foods),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Sticky action row ────────────────────────────────────
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: _ActionRow(
                    isLoading: isLoading,
                    onDelete: () => _confirmDelete(
                      context: context,
                      label: '"${meal.name}"',
                      onConfirmed: () => ref
                          .read(mealOperationsProvider.notifier)
                          .delete(meal.id),
                    ),
                    onEdit: () {
                      Navigator.of(context).pop();
                      context.push(Routes.updateMealPage, extra: meal);
                    },
                  ),
                ),
              ],
            ),
            _CloseButton(onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _FoodItemList extends StatelessWidget {
  final List<Food> foods;
  const _FoodItemList({required this.foods});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCreamTop,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: foods.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
        itemBuilder: (_, i) => _FoodItemTile(food: foods[i]),
      ),
    );
  }
}

class _FoodItemTile extends StatelessWidget {
  final Food food;
  const _FoodItemTile({required this.food});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            child: Icon(Icons.fastfood, size: 13, color: AppColors.secondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name.isNotEmpty ? food.name : 'Food #${food.id}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${food.weightInGrams.toStringAsFixed(0)} g',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  _MiniMacro('P', food.protein, Colors.blue),
                  const SizedBox(width: 4),
                  _MiniMacro('F', food.fat, Colors.amber.shade700),
                  const SizedBox(width: 4),
                  _MiniMacro('C', food.carbs, Colors.green),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniMacro(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label${value.toStringAsFixed(0)}',
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isTemplate;
  final double titleFontSize;

  const _DialogHeader({
    required this.title,
    required this.subtitle,
    required this.isTemplate,
    this.titleFontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headerMedium.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (isTemplate) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Template',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;
  final double fontSize;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: fontSize + 4),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey,
            fontSize: fontSize,
          ),
        ),
        const Spacer(),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ActionRow({
    required this.isLoading,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            onPressed: isLoading ? null : onDelete,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
            onPressed: isLoading ? null : onEdit,
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: const Icon(Icons.close),
        color: AppColors.grey,
        tooltip: 'Close',
        onPressed: onTap,
      ),
    );
  }
}

void _confirmDelete({
  required BuildContext context,
  required String label,
  required Future<void> Function() onConfirmed,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(
        'Are you sure you want to delete $label? This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () async {
            Navigator.of(ctx).pop();
            await onConfirmed();
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
