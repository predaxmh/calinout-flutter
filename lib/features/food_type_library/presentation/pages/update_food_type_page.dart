import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_controller.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_operations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class UpdateFoodTypePage extends ConsumerStatefulWidget {
  final FoodType foodType;

  const UpdateFoodTypePage({super.key, required this.foodType});

  @override
  ConsumerState<UpdateFoodTypePage> createState() => _UpdateFoodTypePageState();
}

class _UpdateFoodTypePageState extends ConsumerState<UpdateFoodTypePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _carbsController;
  late final TextEditingController _baseWeightController;

  @override
  void initState() {
    super.initState();
    // Pre-fill every field with the existing food type values.
    final ft = widget.foodType;
    _nameController = TextEditingController(text: ft.name);
    _caloriesController = TextEditingController(
      text: ft.calories.toStringAsFixed(2),
    );
    _proteinController = TextEditingController(
      text: ft.protein.toStringAsFixed(2),
    );
    _fatController = TextEditingController(text: ft.fat.toStringAsFixed(2));
    _carbsController = TextEditingController(text: ft.carbs.toStringAsFixed(2));
    _baseWeightController = TextEditingController(
      text: ft.baseWeightInGrams.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _baseWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(foodTypeOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) =>
            context.showError(NetworkErrorParser.parseError(error)),
        data: (result) {
          ref.invalidate(foodTypeControllerProvider);
          context.showSuccess('${widget.foodType.name} updated');
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
              // Scrollable content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildInfoCard(),
                    const SizedBox(height: 24),

                    // Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Food Name',
                      hint: 'e.g., Chicken Breast',
                      icon: Icons.food_bank,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Base weight
                    _buildTextField(
                      controller: _baseWeightController,
                      label: 'Base Weight (grams)',
                      hint: '100',
                      icon: Icons.scale,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Base weight is required';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Must be a positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    StatefulBuilder(
                      builder: (context, setLocal) {
                        _baseWeightController.addListener(
                          () => setLocal(() {}),
                        );
                        return Text(
                          'Nutritional Values (per ${_baseWeightController.text}g)',
                          style: AppTextStyles.headerMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Calories
                    _buildTextField(
                      controller: _caloriesController,
                      label: 'Calories',
                      hint: '165',
                      icon: Icons.local_fire_department,
                      keyboardType: TextInputType.number,
                      validator: _validateMacro,
                    ),
                    const SizedBox(height: 16),

                    // Protein + Fat
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _proteinController,
                            label: 'Protein (g)',
                            hint: '31',
                            icon: Icons.fitness_center,
                            keyboardType: TextInputType.number,
                            validator: _validateMacro,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _fatController,
                            label: 'Fat (g)',
                            hint: '3.6',
                            icon: Icons.water_drop,
                            keyboardType: TextInputType.number,
                            validator: _validateMacro,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Carbs
                    _buildTextField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      hint: '0',
                      icon: Icons.grain,
                      keyboardType: TextInputType.number,
                      validator: _validateMacro,
                    ),
                  ]),
                ),
              ),

              // Sticky save button
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
              'Edit the nutritional values for "${widget.foodType.name}"',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.textFieldTextStyle.copyWith(
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.secondary),
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
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,
      validator: validator,
    );
  }

  String? _validateMacro(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final macro = double.tryParse(value);
    if (macro == null || macro < 0) return 'Must be ≥ 0';
    return null;
  }

  Widget _buildSaveButton() {
    final state = ref.watch(foodTypeOperationsProvider);
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
                  final updated = FoodType(
                    id: widget.foodType.id,
                    name: _nameController.text.trim(),
                    calories: double.parse(
                      double.parse(_caloriesController.text).toStringAsFixed(2),
                    ),
                    protein: double.parse(
                      double.parse(_proteinController.text).toStringAsFixed(2),
                    ),
                    fat: double.parse(
                      double.parse(_fatController.text).toStringAsFixed(2),
                    ),
                    carbs: double.parse(
                      double.parse(_carbsController.text).toStringAsFixed(2),
                    ),
                    baseWeightInGrams: double.parse(
                      double.parse(
                        _baseWeightController.text,
                      ).toStringAsFixed(2),
                    ),
                  );

                  await ref
                      .read(foodTypeOperationsProvider.notifier)
                      .updateFoodType(updated);
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
                'UPDATE FOOD TYPE',
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
