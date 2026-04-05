import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';

import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_controller.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void showFoodTypeDetailDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FoodType foodType,
}) {
  showDialog(
    context: context,
    builder: (_) => _FoodTypeDetailDialog(foodType: foodType, widgetRef: ref),
  );
}

/// Internal dialog widget.  Kept private so call-sites use the top-level
/// function above and never depend on the widget directly.
class _FoodTypeDetailDialog extends ConsumerWidget {
  final FoodType foodType;

  final WidgetRef widgetRef;

  const _FoodTypeDetailDialog({
    required this.foodType,
    required this.widgetRef,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(foodTypeOperationsProvider, (prev, next) {
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
        data: (result) {
          ref.invalidate(foodTypeControllerProvider);
          context.showSuccess('${foodType.name} deleted');

          Navigator.of(context).pop();
        },
      );
    });

    final state = ref.watch(foodTypeOperationsProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name
                  Text(
                    foodType.name,
                    style: AppTextStyles.headerMedium.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per ${foodType.baseWeightInGrams.toStringAsFixed(0)} g',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 24),

                  // Macro grid
                  _MacroRow(
                    label: 'Calories',
                    value: foodType.calories,
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _MacroRow(
                    label: 'Protein',
                    value: foodType.protein,
                    unit: 'g',
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _MacroRow(
                    label: 'Fat',
                    value: foodType.fat,
                    unit: 'g',
                    icon: Icons.water_drop,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  _MacroRow(
                    label: 'Carbs',
                    value: foodType.carbs,
                    unit: 'g',
                    icon: Icons.grain,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Delete
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
                          onPressed: isLoading
                              ? null
                              : () => _confirmDelete(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Edit → navigate to UpdateFoodTypePage
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
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  // Pass the full FoodType as GoRouter `extra`
                                  // so UpdateFoodTypePage can pre-fill its fields.
                                  context.push(
                                    Routes.updateFoodTypeScreen,
                                    extra: foodType,
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //  Close × in the top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: AppColors.grey,
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete food type?'),
        content: Text(
          'Are you sure you want to delete "${foodType.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop(); // close confirmation
              await ref
                  .read(foodTypeOperationsProvider.notifier)
                  .delete(foodType.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
