import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/food_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/meal_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/template_food_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/template_meal_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/consumed_at_picker.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/nutrition_log_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

enum _TemplateTab { food, meal }

class QuickLogPage extends ConsumerStatefulWidget {
  const QuickLogPage({super.key});

  @override
  ConsumerState<QuickLogPage> createState() => _QuickLogPageState();
}

class _QuickLogPageState extends ConsumerState<QuickLogPage> {
  _TemplateTab _tab = _TemplateTab.food;

  // Selected template
  Food? _selectedFood;
  Meal? _selectedMeal;

  DateTime? _consumedAt;

  final _foodSearchController = TextEditingController();
  final _mealSearchController = TextEditingController();
  final _foodScrollController = ScrollController();
  final _mealScrollController = ScrollController();

  // Guards the listener
  bool _logInProgress = false;

  @override
  void initState() {
    super.initState();
    _foodScrollController.addListener(_onFoodScroll);
    _mealScrollController.addListener(_onMealScroll);
  }

  @override
  void dispose() {
    _foodSearchController.dispose();
    _mealSearchController.dispose();
    _foodScrollController.dispose();
    _mealScrollController.dispose();
    super.dispose();
  }

  void _onFoodScroll() {
    if (_foodScrollController.position.pixels >=
        _foodScrollController.position.maxScrollExtent * 0.9) {
      ref.read(templateFoodControllerProvider.notifier).loadNextPage();
    }
  }

  void _onMealScroll() {
    if (_mealScrollController.position.pixels >=
        _mealScrollController.position.maxScrollExtent * 0.9) {
      ref.read(templateMealControllerProvider.notifier).loadNextPage();
    }
  }

  bool get _hasSelection =>
      (_tab == _TemplateTab.food && _selectedFood != null) ||
      (_tab == _TemplateTab.meal && _selectedMeal != null);

  // Logging

  Future<void> _log() async {
    final now = _consumedAt ?? DateTime.now();
    _logInProgress = true;
    if (_tab == _TemplateTab.food) {
      final template = _selectedFood!;
      await ref
          .read(foodOperationsProvider.notifier)
          .add(
            template.copyWith(
              id: -1,
              isTemplate: false,
              consumedAt: now,
              createdAt: now,
              updatedAt: null,
              mealId: null,
            ),
          );
    } else {
      final template = _selectedMeal!;
      await ref
          .read(mealOperationsProvider.notifier)
          .add(
            template.copyWith(
              id: -1,
              isTemplate: false,
              consumedAt: now,
              createdAt: now,
              updatedAt: null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Food listener
    ref.listen(foodOperationsProvider, (prev, next) {
      if (!_logInProgress) return;
      next.whenOrNull(
        error: (error, _) {
          _logInProgress = false;
          if (!mounted) return;
          context.showError(NetworkErrorParser.parseError(error));
        },
        data: (_) {
          if (prev?.isLoading != true) return;
          _logInProgress = false;
          if (!mounted) return;
          ref.invalidate(nutritionLogDateRangeProvider);
          context.showSuccess('"${_selectedFood!.name}" logged successfully');
        },
      );
    });

    ref.listen(mealOperationsProvider, (prev, next) {
      if (!_logInProgress) return;
      next.whenOrNull(
        error: (error, _) {
          _logInProgress = false;
          if (!mounted) return;
          context.showError(NetworkErrorParser.parseError(error));
        },
        data: (_) {
          if (prev?.isLoading != true) return;
          _logInProgress = false;
          if (!mounted) return;
          ref.invalidate(nutritionLogDateRangeProvider);
          context.showSuccess('"${_selectedMeal!.name}" logged successfully');
        },
      );
    });

    final isSaving = _tab == _TemplateTab.food
        ? ref
              .watch(foodOperationsProvider)
              .maybeWhen(loading: () => true, orElse: () => false)
        : ref
              .watch(mealOperationsProvider)
              .maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppColors.bgCreamTop,
      appBar: AppBar(
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/images/logo_name_transparent.svg',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _TabToggle(
                  active: _tab,
                  onChanged: (tab) {
                    setState(() {
                      _tab = tab;
                      // Clear selection when switching tabs.
                      _selectedFood = null;
                      _selectedMeal = null;
                    });
                  },
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _tab == _TemplateTab.food
                    ? _SearchBar(
                        controller: _foodSearchController,
                        hint: 'Search food templates…',
                        onChanged: (val) => ref
                            .read(templateFoodSearchQueryProvider.notifier)
                            .setQuery(val),
                      )
                    : _SearchBar(
                        controller: _mealSearchController,
                        hint: 'Search meal templates…',
                        onChanged: (val) => ref
                            .read(templateMealSearchQueryProvider.notifier)
                            .setQuery(val),
                      ),
              ),

              // Template list
              Expanded(
                child: Stack(
                  children: [
                    _tab == _TemplateTab.food
                        ? _FoodTemplateList(
                            scrollController: _foodScrollController,
                            selected: _selectedFood,
                            onSelect: (f) => setState(() => _selectedFood = f),
                            onDelete: (deletedFood) {
                              if (_selectedFood?.id == deletedFood.id) {
                                setState(() => _selectedFood = null);
                              }
                            },
                            bottomPadding: _hasSelection ? 236 : 16,
                          )
                        : _MealTemplateList(
                            scrollController: _mealScrollController,
                            selected: _selectedMeal,
                            onSelect: (m) => setState(() => _selectedMeal = m),
                            onDelete: (deletedMeal) {
                              if (_selectedMeal?.id == deletedMeal.id) {
                                setState(() => _selectedMeal = null);
                              }
                            },
                            bottomPadding: _hasSelection ? 236 : 16,
                          ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 32,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.bgCreamTop.withValues(alpha: 0.0),
                                AppColors.bgCreamTop.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: // Bottom panel: date picker + log button
            AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              offset: _hasSelection ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hasSelection ? 1.0 : 0.0,
                child: _BottomPanel(
                  selectedName: _tab == _TemplateTab.food
                      ? _selectedFood?.name
                      : _selectedMeal?.name,
                  consumedAt: _consumedAt,
                  isSaving: isSaving,
                  onDateChanged: (dt) => setState(() => _consumedAt = dt),
                  onLog: _log,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  Tab toggle
class _TabToggle extends StatelessWidget {
  final _TemplateTab active;
  final ValueChanged<_TemplateTab> onChanged;

  const _TabToggle({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabChip(
            label: 'Food',
            icon: Icons.fastfood_outlined,
            active: active == _TemplateTab.food,
            onTap: () => onChanged(_TemplateTab.food),
          ),
          _TabChip(
            label: 'Meal',
            icon: Icons.restaurant_menu_outlined,
            active: active == _TemplateTab.meal,
            onTap: () => onChanged(_TemplateTab.meal),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppColors.white : AppColors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: active ? AppColors.white : AppColors.grey,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: hint,
      leading: Icon(Icons.search, color: AppColors.secondary),
      elevation: WidgetStateProperty.all(1),
      onChanged: onChanged,
    );
  }
}

class _FoodTemplateList extends ConsumerWidget {
  final ScrollController scrollController;
  final Food? selected;
  final ValueChanged<Food> onSelect;
  final ValueChanged<Food> onDelete;
  final double bottomPadding;
  const _FoodTemplateList({
    required this.scrollController,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(templateFoodControllerProvider);

    return _TemplateListShell(
      asyncState: asyncState.when(
        loading: () => const _LoadingSliver(),
        error: (err, _) => _ErrorSliver(
          message: err.toString(),
          onRetry: () => ref.invalidate(templateFoodControllerProvider),
        ),
        data: (state) {
          final items = state?.items ?? [];
          if (items.isEmpty) {
            return const _EmptySliver(
              message:
                  'No food templates yet.\nMark a food as template to use it here.',
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _FoodTemplateTile(
                food: items[i],
                isSelected: selected?.id == items[i].id,
                onTap: () => onSelect(items[i]),
                ref: ref,
                onDelete: () => onDelete(items[i]),
              ),
              childCount: items.length,
            ),
          );
        },
      ),
      isLoadingMore: asyncState.isLoading && asyncState.hasValue,
      scrollController: scrollController,
      bottomPadding: bottomPadding,
    );
  }
}

class _MealTemplateList extends ConsumerWidget {
  final ScrollController scrollController;
  final Meal? selected;
  final ValueChanged<Meal> onSelect;
  final ValueChanged<Meal> onDelete;
  final double bottomPadding;
  const _MealTemplateList({
    required this.scrollController,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(templateMealControllerProvider);

    return _TemplateListShell(
      asyncState: asyncState.when(
        loading: () => const _LoadingSliver(),
        error: (err, _) => _ErrorSliver(
          message: err.toString(),
          onRetry: () => ref.invalidate(templateMealControllerProvider),
        ),
        data: (state) {
          final items = state?.items ?? [];
          if (items.isEmpty) {
            return const _EmptySliver(
              message:
                  'No meal templates yet.\nMark a meal as template to use it here.',
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _MealTemplateTile(
                meal: items[i],
                isSelected: selected?.id == items[i].id,
                onTap: () => onSelect(items[i]),
                ref: ref,
                onDelete: () => onDelete(items[i]),
              ),
              childCount: items.length,
            ),
          );
        },
      ),
      isLoadingMore: asyncState.isLoading && asyncState.hasValue,
      scrollController: scrollController,
      bottomPadding: bottomPadding,
    );
  }
}

class _TemplateListShell extends StatelessWidget {
  final Widget asyncState;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final double bottomPadding;

  const _TemplateListShell({
    required this.asyncState,
    required this.isLoadingMore,
    required this.scrollController,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: asyncState,
        ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
        // Space so last item is not hidden by bottom panel
        SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
      ],
    );
  }
}

class _FoodTemplateTile extends StatelessWidget {
  final Food food;
  final bool isSelected;
  final VoidCallback onTap;
  final WidgetRef ref;
  final VoidCallback onDelete;

  const _FoodTemplateTile({
    required this.food,
    required this.isSelected,
    required this.onTap,
    required this.ref,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _TemplateTile(
      isSelected: isSelected,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.orange.withValues(alpha: 0.15),
        child: const Icon(
          Icons.fastfood_outlined,
          color: Colors.orange,
          size: 18,
        ),
      ),
      title: food.name.isNotEmpty ? food.name : 'Food #${food.id}',
      subtitle:
          '${food.weightInGrams.toStringAsFixed(0)} g  ·  ${food.calories.toStringAsFixed(0)} kcal',
      macros: [
        _MacroTag('P', food.protein, Colors.blue),
        _MacroTag('F', food.fat, Colors.amber.shade700),
        _MacroTag('C', food.carbs, Colors.green),
      ],
      onDelete: () {
        showFoodLogDetailDialog(
          context: context,
          food: food,
          ref: ref,
          onDeleted: () {
            ref.invalidate(templateFoodControllerProvider);
            onDelete.call();
          },
        );
      },
    );
  }
}

class _MealTemplateTile extends StatelessWidget {
  final Meal meal;
  final bool isSelected;
  final VoidCallback onTap;
  final WidgetRef ref;
  final VoidCallback onDelete;

  const _MealTemplateTile({
    required this.meal,
    required this.isSelected,
    required this.onTap,
    required this.ref,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final foodCount = meal.foods?.length ?? meal.foodIds?.length ?? 0;

    return _TemplateTile(
      isSelected: isSelected,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
        child: Icon(
          Icons.restaurant_menu_outlined,
          color: AppColors.secondary,
          size: 18,
        ),
      ),
      title: meal.name,
      subtitle:
          '$foodCount food${foodCount == 1 ? '' : 's'}  ·  ${meal.totalCalories.toStringAsFixed(0)} kcal',
      macros: [
        _MacroTag('P', meal.totalProtein, Colors.blue),
        _MacroTag('F', meal.totalFat, Colors.amber.shade700),
        _MacroTag('C', meal.totalCarbs, Colors.green),
      ],
      onDelete: () {
        showMealLogDetailDialog(
          context: context,
          meal: meal,
          ref: ref,
          onDeleted: () {
            ref.invalidate(templateMealControllerProvider);
            onDelete.call();
          },
        );
      },
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Widget leading;
  final String title;
  final String subtitle;
  final List<_MacroTag> macros;

  const _TemplateTile({
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.macros,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.07)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...macros.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: m,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                onDelete.call();
              },
              icon: Icon(Icons.delete),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroTag extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroTag(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label ${value.toStringAsFixed(0)}g',
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final String? selectedName;
  final DateTime? consumedAt;
  final bool isSaving;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onLog;

  const _BottomPanel({
    required this.selectedName,
    required this.consumedAt,
    required this.isSaving,
    required this.onDateChanged,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Selected name
          if (selectedName != null) ...[
            Text(
              selectedName!,
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],

          // Date picker
          ConsumedAtPicker(initialValue: consumedAt, onChanged: onDateChanged),
          const SizedBox(height: 16),

          // Log button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: isSaving ? null : onLog,
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'LOG NOW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorSliver extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSliver({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptySliver extends StatelessWidget {
  final String message;
  const _EmptySliver({required this.message});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: AppColors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
