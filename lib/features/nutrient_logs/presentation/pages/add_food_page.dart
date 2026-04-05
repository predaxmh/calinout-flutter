import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_controller.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/food_operations.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/nutrient_logs/presentation/widgets/consumed_at_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  final int? mealId;

  const AddFoodPage({super.key, this.mealId});

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _searchController = TextEditingController();
  final _dropdownScrollController = ScrollController();

  FoodType? _selectedFoodType;
  bool _isTemplate = false;
  bool _showDropdown = false;

  DateTime? _consumedAt;

  // Derived macro values, recalculated whenever weight or selection changes.
  double _calories = 0;
  double _protein = 0;
  double _fat = 0;
  double _carbs = 0;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_recalculateMacros);

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
    super.dispose();
  }

  // ── Macro calculation ────────────────────────────────────────────────────

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

  void _selectFoodType(FoodType ft) {
    setState(() {
      _selectedFoodType = ft;
      _showDropdown = false;
    });
    _searchController.text = ft.name;
    // Clear the riverpod search so the dropdown list resets next time.
    ref.read(foodTypeSearchQueryProvider.notifier).setQuery('');
    _recalculateMacros();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(foodOperationsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) =>
            context.showError(NetworkErrorParser.parseError(error)),
        data: (food) {
          if (food != null) {
            ref.invalidate(nutritionLogDateRangeProvider);
            context.showSuccess(
              '${food.name.isNotEmpty ? food.name : 'Food'} added',
            );
            context.pop();
          }
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
          setState(() => _showDropdown = false);
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

                    // Food type search
                    _buildSectionLabel('Food Type'),
                    const SizedBox(height: 8),
                    _buildFoodTypeSearch(),
                    const SizedBox(height: 24),

                    // Weight
                    _buildSectionLabel('Weight'),
                    const SizedBox(height: 8),
                    _buildWeightField(),
                    const SizedBox(height: 24),

                    // time date
                    ConsumedAtPicker(
                      onChanged: (dt) => setState(() => _consumedAt = dt),
                    ),
                    const SizedBox(height: 24),
                    // Macro preview
                    _buildMacroPreview(),
                    const SizedBox(height: 24),

                    // isTemplate toggle
                    _buildTemplateToggle(),
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

  // Widgets

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
              'Search for a food type, enter the weight you ate, '
              'and macros will be calculated automatically.',
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.headerMedium.copyWith(
        color: AppColors.primary,
        fontSize: 16,
      ),
    );
  }

  // Food type search with live dropdown

  Widget _buildFoodTypeSearch() {
    ref.listen(foodTypeSearchQueryProvider, (prev, next) {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input
        TextFormField(
          controller: _searchController,
          style: AppTextStyles.textFieldTextStyle.copyWith(
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText: 'Search food types…',
            prefixIcon: Icon(Icons.search, color: AppColors.secondary),
            suffixIcon: _selectedFoodType != null
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
                        _selectedFoodType = null;
                        _showDropdown = false;
                        _calories = _protein = _fat = _carbs = 0;
                      });
                    },
                  )
                : null,
            labelText: 'Food Type',
            labelStyle: AppTextStyles.textFieldLableStyle.copyWith(
              fontSize: 14,
              letterSpacing: 1,
            ),
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
            filled: true,
            fillColor: _selectedFoodType != null
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _selectedFoodType != null
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.3),
                width: _selectedFoodType != null ? 2 : 1,
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
          // Once a food type is selected, lock the field (show as read-only).
          readOnly: _selectedFoodType != null,
          onChanged: (val) {
            ref.read(foodTypeSearchQueryProvider.notifier).setQuery(val);
            setState(() => _showDropdown = val.isNotEmpty);
          },
          onTap: () {
            ref.read(foodTypeSearchQueryProvider.notifier).setQuery('');
            if (_selectedFoodType == null) {
              setState(() => _showDropdown = true);
            }
          },
          validator: (_) =>
              _selectedFoodType == null ? 'Please select a food type' : null,
        ),

        // ── Dropdown results ─────────────────────────────────────────────
        if (_showDropdown) _buildDropdown(),

        // ── Selected chip ────────────────────────────────────────────────
        if (_selectedFoodType != null) ...[
          const SizedBox(height: 8),
          _buildSelectedChip(_selectedFoodType!),
        ],
      ],
    );
  }

  Widget _buildDropdown() {
    final asyncState = ref.watch(foodTypeControllerProvider);
    final isFetchingMore = ref.watch(foodTypeIsFetchingMoreProvider);
    return Container(
      margin: const EdgeInsets.only(top: 4),
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
      constraints: const BoxConstraints(maxHeight: 240),
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
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            itemBuilder: (context, index) {
              final ft = items[index];
              if (isFetchingMore && index == items.length - 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return _FoodTypeDropdownTile(
                foodType: ft,
                onTap: () => _selectFoodType(ft),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedChip(FoodType ft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${ft.name} · ${ft.baseWeightInGrams.toStringAsFixed(0)}g base',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '${ft.calories.toStringAsFixed(0)} kcal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

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
        _selectedFoodType != null && (_weightController.text.isNotEmpty);

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
                const Spacer(),
                if (!hasData)
                  Flexible(
                    child: Text(
                      'select food type & weight',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey.withValues(alpha: 0.7),
                      ),
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
                  final ft = _selectedFoodType!;
                  final food = Food(
                    id: -1,
                    // is wired up — e.g. ref.read(authProvider).userId
                    userId: '',
                    // Name is derived server-side from foodTypeId; send empty.
                    name: '',
                    foodTypeId: ft.id,
                    mealId: widget.mealId,
                    weightInGrams: double.parse(
                      double.parse(_weightController.text).toStringAsFixed(2),
                    ),
                    isTemplate: _isTemplate,
                    calories: _calories,
                    protein: _protein,
                    fat: _fat,
                    carbs: _carbs,
                    createdAt: DateTime.now(),
                    consumedAt: _consumedAt ?? DateTime.now(),
                  );

                  await ref.read(foodOperationsProvider.notifier).add(food);
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
                'LOG FOOD',
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

class _FoodTypeDropdownTile extends StatelessWidget {
  final FoodType foodType;
  final VoidCallback onTap;

  const _FoodTypeDropdownTile({required this.foodType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodType.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'per ${foodType.baseWeightInGrams.toStringAsFixed(0)}g · '
                    '${foodType.calories.toStringAsFixed(0)} kcal',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Quick macro pills
            _MiniPill(label: 'P', value: foodType.protein, color: Colors.blue),
            const SizedBox(width: 4),
            _MiniPill(
              label: 'F',
              value: foodType.fat,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: 4),
            _MiniPill(label: 'C', value: foodType.carbs, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(0)}g',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
