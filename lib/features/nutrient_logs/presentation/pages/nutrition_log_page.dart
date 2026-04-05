import 'package:calinout/core/presentation/extensions/doodle_card_list_item_extension.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_content.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/state/nutrition_log_entry.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/nutrition_log_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

///  • Home screen  → wrap in a SizedBox, pass initialRange = last 24 h (default)
///  • History page → pass no argument, show the date picker controls
/// The [showDateRangePicker] flag hides or shows the range control bar.
class NutritionLogPage extends ConsumerStatefulWidget {
  final bool showDateRangePicker;

  const NutritionLogPage({super.key, this.showDateRangePicker = true});

  @override
  ConsumerState<NutritionLogPage> createState() => _NutritionLogPageState();
}

class _NutritionLogPageState extends ConsumerState<NutritionLogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncEntries = ref.watch(nutritionLogControllerProvider);
    final dateRange = ref.watch(nutritionLogDateRangeProvider);
    final dimensions = context.doodleCardResponsive;

    return Column(
      children: [
        //  Date range bar
        if (widget.showDateRangePicker) ...[
          _DateRangeBar(currentRange: dateRange),
          const Divider(height: 1),
        ],
        //  Log list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                ref.read(nutritionLogControllerProvider.notifier).refresh(),
            child: asyncEntries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(err.toString()),
                    TextButton(
                      onPressed: () => ref
                          .read(nutritionLogControllerProvider.notifier)
                          .refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return _EmptyState(
                    range: dateRange,
                    showDateRangePicker: widget.showDateRangePicker,
                  );
                }

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal:
                            (dimensions.screenWidth -
                                dimensions.listHeaderWidth) /
                            2,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsetsGeometry.only(bottom: 10),

                            child: _buildEntryCard(entries[index], dimensions),
                          );
                        }, childCount: entries.length),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(
    NutritionLogEntry entry,
    DoodleCardDimensions dimensions,
  ) {
    return switch (entry) {
      FoodEntry(:final food) => DoodleCard.listItemShapeFood(
        width: dimensions.listItemCardWidth,

        onTap: () => showFoodLogDetailDialog(
          context: context,
          ref: ref,
          food: food,
          onDeleted: () =>
              ref.read(nutritionLogControllerProvider.notifier).refresh(),
        ),
        child: DoodleCardListItem(
          variant: DoodleCardListItemVariant.food,
          dimensions: dimensions,
          data: food.toDoodleCardListItem(),
        ),
      ),
      MealEntry(:final meal) => DoodleCard.listItemShapeMeal(
        width: dimensions.listItemCardWidth,
        onTap: () => showMealLogDetailDialog(
          context: context,
          ref: ref,
          meal: meal,
          onDeleted: () =>
              ref.read(nutritionLogControllerProvider.notifier).refresh(),
        ),
        child: DoodleCardListItem(
          variant: DoodleCardListItemVariant.meal,
          dimensions: dimensions,
          data: meal.toDoodleCardListItem(),
        ),
      ),

      TitleEntry(:final title) => Text(title, style: AppTextStyles.todayText),
    };
  }
}

// Date range bar
class _DateRangeBar extends ConsumerWidget {
  final DateTimeRange currentRange;
  const _DateRangeBar({required this.currentRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('d MMM');
    final label =
        '${fmt.format(currentRange.start)} – ${fmt.format(currentRange.end)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // ── Quick presets ─────────────────────────────────────────────
          _QuickChip(
            label: 'Today',
            onTap: () =>
                ref.read(nutritionLogDateRangeProvider.notifier).setToday(),
          ),
          const SizedBox(width: 8),
          _QuickChip(
            label: '7 d',
            onTap: () =>
                ref.read(nutritionLogDateRangeProvider.notifier).setLastDays(7),
          ),
          const SizedBox(width: 8),
          _QuickChip(
            label: '30 d',
            onTap: () => ref
                .read(nutritionLogDateRangeProvider.notifier)
                .setLastDays(30),
          ),
          const Spacer(),

          // ── Custom range picker ───────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: currentRange,
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      secondary: AppColors.secondary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                ref
                    .read(nutritionLogDateRangeProvider.notifier)
                    .setRange(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.date_range, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Empty state
class _EmptyState extends ConsumerWidget {
  final DateTimeRange range;
  final bool showDateRangePicker;
  const _EmptyState({required this.range, required this.showDateRangePicker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('d MMM');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_food_outlined,
              size: 56,
              color: AppColors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No entries for\n'
              '${fmt.format(range.start)} – ${fmt.format(range.end)}',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.grey,
                fontSize: 16,
              ),
            ),
            if (showDateRangePicker) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref
                    .read(nutritionLogDateRangeProvider.notifier)
                    .setLastDays(30),
                child: const Text('Expand to last 30 days'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
