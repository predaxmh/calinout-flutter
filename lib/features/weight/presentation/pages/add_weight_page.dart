import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/home_manager/presentation/controllers/daily_log_controller.dart';
import 'package:calinout/features/weight/presentation/controllers/weight_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AddWeightPage extends ConsumerStatefulWidget {
  const AddWeightPage({super.key});

  @override
  ConsumerState<AddWeightPage> createState() => _AddWeightPageState();
}

class _AddWeightPageState extends ConsumerState<AddWeightPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  DateTime? _date;
  bool _saveInProgress = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    final date = _date ?? DateTime.now();

    setState(() => _saveInProgress = true);

    try {
      await ref
          .read(dailyLogControllerProvider.notifier)
          .updateWeight(weight, date);

      // Sync weight history list — no full refetch needed
      ref.read(weightHistoryControllerProvider.notifier).refresh();

      if (!mounted) return;
      context.showSuccess(
        '${weight.toStringAsFixed(1)} kg logged for '
        '${date.day}/${date.month}/${date.year}',
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showError(NetworkErrorParser.parseError(e));
    } finally {
      if (mounted) setState(() => _saveInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        behavior: HitTestBehavior.translucent,
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Info card ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'One weight entry per day. '
                              'If you already logged weight for the selected date it will be updated.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Weight field ───────────────────────────────────
                    Text(
                      'Weight',
                      style: AppTextStyles.headerMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _weightController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.textFieldTextStyle.copyWith(
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                      decoration: InputDecoration(
                        hintText: '70.0',
                        suffixText: 'kg',
                        suffixStyle: TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: Icon(
                          Icons.monitor_weight_outlined,
                          color: AppColors.secondary,
                        ),
                        hintStyle: TextStyle(
                          color: AppColors.grey.withValues(alpha: 0.4),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
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
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}\.?\d{0,1}'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter your weight';
                        }
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) {
                          return 'Enter a valid weight';
                        }
                        if (val > 500) return 'That seems too high';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Date picker ────────────────────────────────────
                  ]),
                ),
              ),

              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(),
                      SizedBox(
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
                          onPressed: _saveInProgress ? null : _save,
                          child: _saveInProgress
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SAVE WEIGHT',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
