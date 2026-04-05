import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/meal_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/consumed_at_picker.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/meal_food_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AddMealPage extends ConsumerStatefulWidget {
  const AddMealPage({super.key});

  @override
  ConsumerState<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends ConsumerState<AddMealPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();

  bool _isTemplate = false;
  bool _builderOpen = false;
  final List<FoodDraft> _foods = [];
  DateTime? _consumedAt;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnim;

  // Totals
  double get _totalCalories => _foods.fold(0, (s, f) => s + f.calories);
  double get _totalProtein => _foods.fold(0, (s, f) => s + f.protein);
  double get _totalFat => _foods.fold(0, (s, f) => s + f.fat);
  double get _totalCarbs => _foods.fold(0, (s, f) => s + f.carbs);
  double get _totalWeight => _foods.fold(0, (s, f) => s + f.weightInGrams);
  double _r(double v) => double.parse(v.toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  // Food management

  void _addDraft(FoodDraft draft) {
    setState(() {
      _foods.add(draft);
      _builderOpen = false;
    });
    _expandController.reverse();
    _listKey.currentState?.insertItem(
      _foods.length - 1,
      duration: const Duration(milliseconds: 300),
    );
    // Scroll down so the new card is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeDraft(int index) {
    final removed = _foods[index];
    _foods.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (ctx, anim) => _buildFoodCard(removed, index, anim),
      duration: const Duration(milliseconds: 250),
    );
    setState(() {});
  }

  void _duplicateDraft(int index) {
    final copy = _foods[index];
    setState(() => _foods.insert(index + 1, copy));
    _listKey.currentState?.insertItem(
      index + 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _toggleBuilder() {
    setState(() => _builderOpen = !_builderOpen);
    if (_builderOpen) {
      _expandController.forward();
      // Scroll to builder after frame renders.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mealOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) =>
            context.showError(NetworkErrorParser.parseError(error)),
        data: (meal) {
          if (meal != null) {
            ref.invalidate(nutritionLogDateRangeProvider);
            context.showSuccess('Meal created');
            context.pop();
          }
        },
      );
    });

    final isSaving = ref
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
      body: Column(
        children: [
          // Scrollable form
          Expanded(
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        _buildNameField(),
                        const SizedBox(height: 24),
                        ConsumedAtPicker(
                          onChanged: (dt) => setState(() => _consumedAt = dt),
                        ),
                        const SizedBox(height: 24),
                        _buildTemplateToggle(),
                        const SizedBox(height: 24),

                        //  Foods header
                        _buildFoodsHeader(),
                        const SizedBox(height: 8),

                        // Animated food list
                        if (_foods.isNotEmpty)
                          AnimatedList(
                            key: _listKey,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _foods.length,
                            itemBuilder: (ctx, i, anim) =>
                                _buildFoodCard(_foods[i], i, anim),
                          ),

                        // Add food toggle
                        const SizedBox(height: 8),
                        _buildAddFoodToggle(),

                        SizeTransition(
                          sizeFactor: _expandAnim,
                          axisAlignment: -1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _buildInlineBuilder(),
                          ),
                        ),

                        const SizedBox(height: 160),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildStickyBottom(isSaving),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Build your meal by adding foods one by one. '
              'Each food\'s macros are calculated from its type and weight.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: AppTextStyles.textFieldTextStyle.copyWith(
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        labelText: 'Meal Name',
        hintText: 'e.g., Post-workout lunch',
        prefixIcon: Icon(Icons.restaurant_menu, color: AppColors.secondary),
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
      inputFormatters: [LengthLimitingTextInputFormatter(80)],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Name is required';
        if (v.trim().length < 2) return 'At least 2 characters';
        return null;
      },
    );
  }

  Widget _buildTemplateToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark_outline, color: AppColors.secondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save as Template',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'All foods will also be saved as templates.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isTemplate,
            activeThumbColor: AppColors.secondary,
            onChanged: (val) => setState(() => _isTemplate = val),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodsHeader() {
    return Row(
      children: [
        Text(
          'Foods',
          style: AppTextStyles.headerMedium.copyWith(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        if (_foods.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_foods.length}',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFoodCard(
    FoodDraft draft,
    int index,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Dismissible(
          key: ValueKey('${draft.foodType.id}-$index-${draft.weightInGrams}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (_) => _removeDraft(index),
          child: _FoodDraftCard(
            draft: draft,
            isTemplate: _isTemplate,
            onRemove: () => _removeDraft(index),
            onDuplicate: () => _duplicateDraft(index),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFoodToggle() {
    return GestureDetector(
      onTap: _toggleBuilder,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _builderOpen
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _builderOpen
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            width: _builderOpen ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: _builderOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.add_circle_outline,
                color: _builderOpen ? AppColors.primary : AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _builderOpen ? 'Cancel' : 'Add a Food',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _builderOpen ? AppColors.primary : AppColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _builderOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineBuilder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'New Food',
                style: AppTextStyles.headerMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isTemplate) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Template',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          MealFoodBuilder(
            isTemplate: _isTemplate,
            onAdd: _addDraft,
            confirmLabel: 'Add to Meal',
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottom(bool isSaving) {
    final has = _foods.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live totals row
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: has ? 1.0 : 0.35,
            child: Row(
              children: [
                _StickyMacro(
                  _totalCalories.toStringAsFixed(0),
                  'kcal',
                  Colors.orange,
                ),
                _StickyDivider(),
                _StickyMacro(
                  '${_totalProtein.toStringAsFixed(1)}g',
                  'protein',
                  Colors.blue,
                ),
                _StickyDivider(),
                _StickyMacro(
                  '${_totalFat.toStringAsFixed(1)}g',
                  'fat',
                  Colors.amber.shade700,
                ),
                _StickyDivider(),
                _StickyMacro(
                  '${_totalCarbs.toStringAsFixed(1)}g',
                  'carbs',
                  Colors.green,
                ),
                _StickyDivider(),
                _StickyMacro(
                  '${_totalWeight.toStringAsFixed(0)}g',
                  'total',
                  AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Save button
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
              onPressed: isSaving || !has
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final now = DateTime.now();
                      final meal = Meal(
                        id: -1,
                        userId: '',
                        name: _nameController.text.trim(),
                        isTemplate: _isTemplate,
                        totalCalories: _r(_totalCalories),
                        totalProtein: _r(_totalProtein),
                        totalFat: _r(_totalFat),
                        totalCarbs: _r(_totalCarbs),
                        totalWeight: _r(_totalWeight),
                        consumedAt: _consumedAt ?? DateTime.now(),
                        createdAt: now,
                        foods: _foods
                            .map(
                              (d) => d.toFood(
                                isTemplate: _isTemplate,
                                consumeAt: _consumedAt,
                              ),
                            )
                            .toList(),
                        foodIds: [],
                      );
                      await ref.read(mealOperationsProvider.notifier).add(meal);
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      has
                          ? 'CREATE MEAL  (${_foods.length} food${_foods.length == 1 ? '' : 's'})'
                          : 'ADD FOODS FIRST',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodDraftCard extends StatelessWidget {
  final FoodDraft draft;
  final bool isTemplate;
  final VoidCallback onRemove;
  final VoidCallback onDuplicate;

  const _FoodDraftCard({
    required this.draft,
    required this.isTemplate,
    required this.onRemove,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange.withValues(alpha: 0.15),
            child: const Icon(
              Icons.fastfood_outlined,
              color: Colors.orange,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.foodType.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${draft.weightInGrams.toStringAsFixed(0)} g  ·  '
                  '${draft.calories.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _Pill(
                      'P ${draft.protein.toStringAsFixed(0)}g',
                      Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    _Pill(
                      'F ${draft.fat.toStringAsFixed(0)}g',
                      Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    _Pill('C ${draft.carbs.toStringAsFixed(0)}g', Colors.green),
                    if (isTemplate) ...[
                      const SizedBox(width: 4),
                      _Pill('Template', AppColors.secondary),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_outlined,
              size: 18,
              color: AppColors.grey.withValues(alpha: 0.7),
            ),
            tooltip: 'Duplicate',
            onPressed: onDuplicate,
          ),
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              size: 18,
              color: AppColors.error,
            ),
            tooltip: 'Remove',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StickyMacro extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StickyMacro(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(label, style: TextStyle(color: AppColors.grey, fontSize: 9)),
        ],
      ),
    );
  }
}

class _StickyDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.primary.withValues(alpha: 0.1),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
