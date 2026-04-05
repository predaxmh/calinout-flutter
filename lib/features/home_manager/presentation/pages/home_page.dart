import 'package:calinout/core/presentation/extensions/doodle_card_list_item_extension.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_content.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/value_formatter.dart';
import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';
import 'package:calinout/features/home_manager/presentation/controllers/daily_log_controller.dart';
import 'package:calinout/features/home_manager/presentation/widgets/daily_note_dialog.dart';
import 'package:calinout/features/home_manager/presentation/widgets/home_extra_data_bar.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/state/nutrition_log_entry.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/nutrition_log_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final controller = TextEditingController();
  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.95) {}
  }

  @override
  Widget build(BuildContext context) {
    final homeDashboardState = ref.watch(dailyLogControllerProvider);
    final asyncEntries = ref.watch(nutritionLogControllerProvider);
    final dimensions = context.doodleCardResponsive;

    return CustomScrollView(
      slivers: [
        SliverPadding(padding: EdgeInsets.only(top: dimensions.screenPadding)),
        homeDashboardState.when(
          loading: () => SliverToBoxAdapter(
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (err, stack) =>
              SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          data: (data) {
            return SliverToBoxAdapter(
              child: Align(
                child: Column(
                  children: [
                    _HomeStatsSection(
                      dailyLog: data,
                      dimensions: dimensions,
                      extraCotroller: controller,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: dimensions.listHeaderWidth,
                      child: HomeExtraDataBar(
                        isDigestiveCleared: (data == null)
                            ? false
                            : data.digestiveTrackCleared,
                        isCheatDay: (data == null) ? false : data.isCheatDay,
                        onToggleDigestive: () => ref
                            .read(dailyLogControllerProvider.notifier)
                            .toggleDigestiveTrack(),
                        onToggleCheatDay: () => ref
                            .read(dailyLogControllerProvider.notifier)
                            .toggleCheatDay(),
                        onAddNote: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => DailyNoteDialog(
                              initialNote: (data == null)
                                  ? ''
                                  : data.dailyNotes,
                              onSave: (text) => ref
                                  .read(dailyLogControllerProvider.notifier)
                                  .updateDailyNote(text),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Align(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.screenPadding,
                vertical: dimensions.screenPadding,
              ),
              child: _TodayActivitySection(dimensions: dimensions),
            ),
          ),
        ),

        asyncEntries.when(
          loading: () => SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
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
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return SliverToBoxAdapter(child: _EmptyState());
            }

            return SliverPadding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal:
                    (dimensions.screenWidth - dimensions.listHeaderWidth) / 2,
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
            );
          },
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

      TitleEntry() => SizedBox(),
    };
  }
}

class _HomeStatsSection extends ConsumerWidget {
  final DoodleCardDimensions dimensions;
  final DailyLog? dailyLog;
  final TextEditingController extraCotroller;
  const _HomeStatsSection({
    required this.dimensions,
    required this.dailyLog,
    required this.extraCotroller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extraData = ref.watch(extraDataControlProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─────────────────────────────────────────────────────────
        // ROW 1: Primary Stats (Goal, Calorie In, Basal Base)
        // ─────────────────────────────────────────────────────────
        Row(
          spacing: dimensions.cardGapHorizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            DoodleCard.topLeftBackShape(
              width: dimensions.topLeftBackWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: VerticalLabelNumber(
                  label: 'Goal:',
                  number: dailyLog == null
                      ? '0'
                      : dailyLog!.targetCalorieOnThisDay.toString(),
                  unit: 'C',
                  labelSize: dimensions.cardLabelSize,
                  numberSize: dimensions.cardNumberSize,
                ),
              ),
              onTap: () => _showFullTextDialog(
                context,
                'Goal',
                extraCotroller,
                () => ref
                    .read(dailyLogControllerProvider.notifier)
                    .goalCaloriesSet(int.parse(extraCotroller.text)),
              ),
            ),
            DoodleCard.topBackShape(
              width: dimensions.topBackWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: VerticalLabelNumber(
                  label: 'Calorie In:',
                  number: dailyLog == null
                      ? '0'
                      : dailyLog!.totalCalories.toString(),
                  unit: 'C',
                  labelSize: dimensions.topBackLabelSize,
                  numberSize: dimensions.topBackNumberSize,
                ),
              ),
            ),
            DoodleCard.bottomRightBackShape(
              width: dimensions.bottomRightBackWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: VerticalLabelNumber(
                  label: 'B.Base:',
                  number: extraData!.bodyBaseCalories.toString(),
                  unit: 'C',
                  labelSize: dimensions.cardLabelSize,
                  numberSize: dimensions.cardNumberSize,
                ),
              ),
              onTap: () => _showFullTextDialog(
                context,
                'Body Base',
                extraCotroller,
                () => ref
                    .read(dailyLogControllerProvider.notifier)
                    .goalCaloriesSet(int.parse(extraCotroller.text)),
              ),
            ),
          ],
        ),
        // this because the main topBackShape is bigger, and the normal gap is to far, this looks good
        SizedBox(height: (dimensions.cardGapVertical / 2)),

        // ─────────────────────────────────────────────────────────
        // ROW 2: Activity Stats (Burned, Maintenance, Weight)
        // ─────────────────────────────────────────────────────────
        Row(
          spacing: dimensions.cardGapHorizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            DoodleCard.topLeftBackShape(
              width: dimensions.topLeftBackWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: VerticalLabelNumber(
                  label: 'C.burned:',
                  number: dailyLog == null
                      ? '0'
                      : dailyLog!.burnedCalories.toString(),
                  unit: 'C',
                  labelSize: dimensions.cardLabelSize,
                  numberSize: dimensions.cardNumberSize,
                ),
              ),
              onTap: () => _showFullTextDialog(
                context,
                'Calorie burned',
                extraCotroller,
                () => ref
                    .read(dailyLogControllerProvider.notifier)
                    .burnedCaloriesSet(int.parse(extraCotroller.text)),
              ),
            ),
            DoodleCard.bottomBack(
              width: dimensions.bottomBackWidth,

              child: HorizontalLabelNumber(
                label: 'Main:',
                number: extraData.maintenanceCalories.toString(),
                unit: 'C',
                labelSize: dimensions.cardLabelSize,
                numberSize: dimensions.cardNumberSize,
              ),
            ),
            DoodleCard.bottomRightBackShape(
              width: dimensions.bottomRightBackWidth,

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: VerticalLabelNumber(
                  label: 'F.Weight:',
                  number: ValueFormatter.formatNumber(
                    dailyLog == null ? 0 : dailyLog!.totalFoodWeight,
                  ),
                  unit: 'G',
                  labelSize: dimensions.cardLabelSize,
                  numberSize: dimensions.cardNumberSize,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: dimensions.cardGapVertical),
        // ─────────────────────────────────────────────────────────
        // ROW 3: Macronutrients (Carb, Fat, Protein)
        // ─────────────────────────────────────────────────────────
        Row(
          spacing: dimensions.cardGapHorizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            DoodleCard.tinyBottomBackShape(
              width: dimensions.tinyBackWidth,

              surfaceColor: AppColors.secondary,
              backgroundColor: AppColors.black,
              child: HorizontalLabelNumber(
                label: 'Carb:',
                number: ValueFormatter.formatNumber(
                  dailyLog == null ? 0 : dailyLog!.totalCarbs,
                ),
                unit: 'G',
                numberColor: AppColors.white,
                labelColor: AppColors.black,
                labelSize: dimensions.cardLabelSize,
                numberSize: dimensions.cardNumberSize,
              ),
            ),
            DoodleCard.tinyBottomBackShape(
              width: dimensions.tinyBackWidth,
              surfaceColor: AppColors.primary,
              backgroundColor: AppColors.black,
              child: HorizontalLabelNumber(
                label: 'Fat:',
                number: ValueFormatter.formatNumber(
                  dailyLog == null ? 0 : dailyLog!.totalFat,
                ),
                unit: 'G',
                numberColor: AppColors.white,
                labelColor: AppColors.black,
                labelSize: dimensions.cardLabelSize,
                numberSize: dimensions.cardNumberSize,
              ),
            ),
            DoodleCard.tinyBottomBackShape(
              width: dimensions.tinyBackWidth,
              surfaceColor: AppColors.secondary,
              backgroundColor: AppColors.black,
              child: Semantics(
                // todo later
                label: 'Protein',
                child: HorizontalLabelNumber(
                  label: 'Prot:',
                  number: ValueFormatter.formatNumber(
                    dailyLog == null ? 0 : dailyLog!.totalProtein,
                  ),
                  unit: 'G',
                  numberColor: AppColors.white,
                  labelColor: AppColors.black,
                  labelSize: dimensions.cardLabelSize,
                  numberSize: dimensions.cardNumberSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFullTextDialog(
    BuildContext context,
    String labalText,
    TextEditingController goalController,
    VoidCallback onPress,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _ChangeExtraDataForm(
          goalController: goalController,
          labalText: labalText,
          onPress: onPress,
        );
      },
    );
  }
}

class _ChangeExtraDataForm extends ConsumerWidget {
  final TextEditingController goalController;
  final VoidCallback onPress;
  final String labalText;

  const _ChangeExtraDataForm({
    required this.goalController,
    required this.onPress,
    required this.labalText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(
        'Change $labalText',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: TextFormField(
          controller: goalController,
          keyboardType: TextInputType.number,
          style: AppTextStyles.textFieldTextStyle.copyWith(
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            labelText: labalText,
            hintText: '2600',
            prefixIcon: Icon(Icons.change_circle, color: AppColors.primaryDark),
            suffixText: 'c',
            labelStyle: AppTextStyles.textFieldLableStyle.copyWith(
              fontSize: 14,
              letterSpacing: 1,
            ),
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            errorStyle: AppTextStyles.erroTextStyle.copyWith(
              color: AppColors.error,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return '$labalText is required';
            final w = double.tryParse(value);
            if (w == null || w <= 0) return 'Must be a positive number';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () => {onPress.call(), Navigator.of(context).pop()},
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class _TodayActivitySection extends StatelessWidget {
  final DoodleCardDimensions dimensions;
  const _TodayActivitySection({required this.dimensions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dimensions.listHeaderWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'Today:',
            style: AppTextStyles.todayText.copyWith(
              fontSize: dimensions.todayTextSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              'Today',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
