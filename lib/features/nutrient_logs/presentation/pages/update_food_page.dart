import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/food_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/consumed_at_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// GoRouter extra: `{'food': Food, 'foodType': FoodType}`
class UpdateFoodPage extends ConsumerStatefulWidget {
  final Food food;

  final FoodType? initialFoodType;

  const UpdateFoodPage({super.key, required this.food, this.initialFoodType});

  @override
  ConsumerState<UpdateFoodPage> createState() => _UpdateFoodPageState();
}

class _UpdateFoodPageState extends ConsumerState<UpdateFoodPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  final _searchController = TextEditingController();

  FoodType? _selectedFoodType;
  late bool _isTemplate;
  DateTime? _consumedAt;
  double _calories = 0;
  double _protein = 0;
  double _fat = 0;
  double _carbs = 0;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.food.weightInGrams.toStringAsFixed(2),
    );
    _isTemplate = widget.food.isTemplate;

    if (widget.initialFoodType != null) {
      _selectedFoodType = widget.initialFoodType;
      _searchController.text = widget.initialFoodType!.name;
    }
    _consumedAt = widget.food.consumedAt;
    _weightController.addListener(_recalculateMacros);

    _calories = widget.food.calories;
    _protein = widget.food.protein;
    _fat = widget.food.fat;
    _carbs = widget.food.carbs;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Macro calculation

  void _recalculateMacros() {
    final ft = _selectedFoodType;
    if (ft == null) return;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final ratio = weight / ft.baseWeightInGrams;
    setState(() {
      _calories = _round(ft.calories * ratio);
      _protein = _round(ft.protein * ratio);
      _fat = _round(ft.fat * ratio);
      _carbs = _round(ft.carbs * ratio);
    });
  }

  double _round(double v) => double.parse(v.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    ref.listen(foodOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) =>
            context.showError(NetworkErrorParser.parseError(error)),
        data: (result) {
          context.showSuccess('Food entry updated');
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
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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

                    _buildSectionLabel('Weight'),
                    const SizedBox(height: 8),
                    _buildWeightField(),
                    const SizedBox(height: 24),
                    // time date
                    ConsumedAtPicker(
                      initialValue: _consumedAt,
                      onChanged: (dt) => setState(() => _consumedAt = dt),
                    ),
                    const SizedBox(height: 24),
                    _buildMacroPreview(),
                    const SizedBox(height: 24),
                    _buildTemplateToggle(),
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
              'Update the food type or weight — macros will recalculate automatically.',
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

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: AppTextStyles.headerMedium.copyWith(
      color: AppColors.primary,
      fontSize: 16,
    ),
  );

  Widget _buildWeightField() {
    return TextFormField(
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
        if (value == null || value.isEmpty) return 'Weight is required';
        final w = double.tryParse(value);
        if (w == null || w <= 0) return 'Must be a positive number';
        return null;
      },
    );
  }

  Widget _buildMacroPreview() {
    final hasData =
        _selectedFoodType != null && _weightController.text.isNotEmpty;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: hasData ? 1.0 : 0.4,
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
                  'Calculated Macros',
                  style: AppTextStyles.headerMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MacroChip(
                  label: 'Calories',
                  value: _calories,
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Protein',
                  value: _protein,
                  unit: 'g',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Fat',
                  value: _fat,
                  unit: 'g',
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Carbs',
                  value: _carbs,
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
                  'Templates can be reused across meals quickly.',
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

  Widget _buildSaveButton() {
    final state = ref.watch(foodOperationsProvider);
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
                  final updated = widget.food.copyWith(
                    weightInGrams: double.parse(
                      double.parse(_weightController.text).toStringAsFixed(2),
                    ),
                    isTemplate: _isTemplate,
                    consumedAt: _consumedAt ?? DateTime.now(),
                  );
                  await ref
                      .read(foodOperationsProvider.notifier)
                      .updateFood(updated);
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
                'UPDATE FOOD',
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
