import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/food_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/meal_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/consumed_at_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// GoRouter extra: the [Meal] to edit.
class UpdateMealPage extends ConsumerStatefulWidget {
  final Meal meal;
  const UpdateMealPage({super.key, required this.meal});

  @override
  ConsumerState<UpdateMealPage> createState() => _UpdateMealPageState();
}

class _UpdateMealPageState extends ConsumerState<UpdateMealPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late bool _isTemplate;
  DateTime? _consumedAt;

  /// Pre-seeded from meal.foods in initState — no async needed.
  late final List<Food> _selectedFoods;

  // ── Totals ────────────────────────────────────────────────────────────────

  double get _totalCalories => _selectedFoods.fold(0, (s, f) => s + f.calories);
  double get _totalProtein => _selectedFoods.fold(0, (s, f) => s + f.protein);
  double get _totalFat => _selectedFoods.fold(0, (s, f) => s + f.fat);
  double get _totalCarbs => _selectedFoods.fold(0, (s, f) => s + f.carbs);
  double get _totalWeight =>
      _selectedFoods.fold(0, (s, f) => s + f.weightInGrams);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.name);
    _isTemplate = widget.meal.isTemplate;
    // Seed directly — meal already carries its foods from the API.
    _selectedFoods = List<Food>.from(widget.meal.foods ?? []);
    _scrollController.addListener(_onScroll);
    _consumedAt = widget.meal.consumedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(foodControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mealOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) =>
            context.showError(NetworkErrorParser.parseError(error)),
        data: (result) {
          context.showSuccess('Meal entry updated');
          ref.invalidate(nutritionLogControllerProvider);
          context.pop();
        },
      );
    });

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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildNameField(),
                    const SizedBox(height: 24),
                    // ── time date ───────────────────────────────────────────
                    ConsumedAtPicker(
                      initialValue: _consumedAt,
                      onChanged: (dt) => setState(() => _consumedAt = dt),
                    ),
                    const SizedBox(height: 24),
                    _buildTemplateToggle(),
                    const SizedBox(height: 24),
                    _buildSectionLabel(
                      'Foods in this Meal',
                      trailing: _selectedFoods.isNotEmpty
                          ? Text(
                              '${_selectedFoods.length} selected',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    // _buildFoodSearch(),
                    // const SizedBox(height: 8),
                    // if (_showFoodPicker) ...[
                    //   _buildFoodPickerPanel(),
                    //   const SizedBox(height: 8),
                    // ],
                    // if (_selectedFoods.isNotEmpty) ...[
                    //   const SizedBox(height: 8),
                    //   _buildSelectedFoodsList(),
                    // ],
                    const SizedBox(height: 24),
                    _buildMacroTotals(),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [const Spacer(), _buildSaveButton()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

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
          Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Edit "${widget.meal.name}" — add or remove foods, or rename.',
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

  Widget _buildSectionLabel(String label, {Widget? trailing}) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.headerMedium.copyWith(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing],
      ],
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Name is required';
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }

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
                  'Reuse this meal composition quickly in the future.',
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

  Widget _buildMacroTotals() {
    final hasSelections = _selectedFoods.isNotEmpty;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: hasSelections ? 1.0 : 0.4,
      child: Container(
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
                Icon(Icons.auto_graph, color: AppColors.secondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Meal Totals',
                  style: AppTextStyles.headerMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (hasSelections)
                  Text(
                    '${_totalWeight.toStringAsFixed(0)} g total',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MacroChip(
                  label: 'Calories',
                  value: _totalCalories,
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Protein',
                  value: _totalProtein,
                  unit: 'g',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Fat',
                  value: _totalFat,
                  unit: 'g',
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Carbs',
                  value: _totalCarbs,
                  unit: 'g',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final state = ref.watch(mealOperationsProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  final updated = widget.meal.copyWith(
                    name: _nameController.text.trim(),
                    isTemplate: _isTemplate,

                    foodIds: _selectedFoods.map((f) => f.id).toList(),
                    consumedAt: _consumedAt ?? DateTime.now(),
                  );
                  await ref
                      .read(mealOperationsProvider.notifier)
                      .updateMeal(updated);
                }
              },
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'UPDATE MEAL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$label ($unit)',
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
