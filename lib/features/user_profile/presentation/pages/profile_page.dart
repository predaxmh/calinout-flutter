import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';
import 'package:calinout/features/user_profile/presentation/controllers/profile_controller.dart';
import 'package:calinout/features/user_profile/presentation/widgets/birth_date_picker.dart';
import 'package:calinout/features/user_profile/presentation/widgets/gender_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileControllerProvider);

    return asyncProfile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _ErrorBody(
        message: NetworkErrorParser.parseError(err),
        onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
      ),
      data: (profile) => _ProfileForm(profile: profile),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  final UserProfile? profile;
  const _ProfileForm({required this.profile});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  late MeasurementSystem _measurementSystem;
  late DateTime? _birthDate;
  bool _updateInProgress = false;
  late Gender? _gender;

  bool _isDirty = false;

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _heightController = TextEditingController(
      text: p?.heightInCm != null ? p!.heightInCm!.toStringAsFixed(1) : '',
    );
    _weightController = TextEditingController(
      text: p?.weightInKg != null ? p!.weightInKg!.toStringAsFixed(1) : '',
    );
    _measurementSystem = p?.measurementSystem ?? MeasurementSystem.metric;
    _birthDate = p?.birthDate;
    _gender = p?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // ── Height/weight labels change with measurement system ─────────────────

  String get _heightLabel => _measurementSystem == MeasurementSystem.metric
      ? 'Height (cm)'
      : 'Height (in)';

  String get _weightLabel => _measurementSystem == MeasurementSystem.metric
      ? 'Weight (kg)'
      : 'Weight (lbs)';

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(profileOperationsProvider, (prev, next) {
      if (!_updateInProgress) return;

      next.whenOrNull(
        error: (error, _) {
          _updateInProgress = false;
          if (!mounted) return;
          context.showError(NetworkErrorParser.parseError(error));
        },
        data: (_) {
          if (prev?.isLoading != true) return;
          _updateInProgress = false;
          if (!mounted) return;
          setState(() => _isDirty = false);
          context.showSuccess('Profile updated');
        },
      );
    });

    final isSaving = ref
        .watch(profileOperationsProvider)
        .maybeWhen(loading: () => true, orElse: () => false);

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isDirty ? _buildDirtyBanner() : const SizedBox.shrink(),
        ),

        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _formKey,
              child: RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: () =>
                    ref.read(profileControllerProvider.notifier).refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── Avatar + name header ─────────────────────────────
                          _buildAvatarHeader(),
                          const SizedBox(height: 28),

                          // ── Personal info ────────────────────────────────────
                          _buildSectionLabel('Personal Info'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            icon: Icons.person_outline,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            icon: Icons.person_outline,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionLabel('Gender'),
                          const SizedBox(height: 12),
                          GenderSelector(
                            selected: _gender,
                            onChanged: (g) {
                              _markDirty();
                              setState(() => _gender = g);
                            },
                          ),
                          const SizedBox(height: 28),
                          BirthDatePicker(
                            initialValue: widget.profile?.birthDate,
                            onChanged: (dt) {
                              _markDirty();
                              setState(() => _birthDate = dt);
                            },
                          ),
                          const SizedBox(height: 28),

                          // ── Measurement system ───────────────────────────────
                          _buildSectionLabel('Measurement System'),
                          const SizedBox(height: 12),
                          _buildMeasurementToggle(),
                          const SizedBox(height: 28),

                          // ── Body metrics ─────────────────────────────────────
                          _buildSectionLabel('Body Metrics'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _heightController,
                                  label: _heightLabel,
                                  icon: Icons.height,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,1}'),
                                    ),
                                  ],
                                  validator: _validatePositiveDecimal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _weightController,
                                  label: _weightLabel,
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,1}'),
                                    ),
                                  ],
                                  validator: _validatePositiveDecimal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
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
                            _buildSaveButton(isSaving),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────

  Widget _buildAvatarHeader() {
    final displayName = [
      _firstNameController.text,
      _lastNameController.text,
    ].where((s) => s.isNotEmpty).join(' ');

    final initials = [
      _firstNameController.text.isNotEmpty ? _firstNameController.text[0] : '',
      _lastNameController.text.isNotEmpty ? _lastNameController.text[0] : '',
    ].join().toUpperCase();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            child: Text(
              initials.isNotEmpty ? initials : '?',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (displayName.isNotEmpty)
            Text(
              displayName,
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          if (widget.profile?.email != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: AppColors.grey.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.profile!.email!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.withValues(alpha: 0.9),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          Text(
            'Tap fields below to edit',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
              fontSize: 12,
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
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter> inputFormatters = const [],
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
      inputFormatters: inputFormatters,
      validator: validator,
      // Rebuild avatar header initials live
      onChanged: (_) {
        _markDirty();
        setState(() {});
      },
    );
  }

  Widget _buildMeasurementToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _MeasurementChip(
            label: 'Metric',
            subtitle: 'cm / kg',
            active: _measurementSystem == MeasurementSystem.metric,
            onTap: () {
              _markDirty();
              setState(() => _measurementSystem = MeasurementSystem.metric);
            },
          ),
          _MeasurementChip(
            label: 'Imperial',
            subtitle: 'in / lbs',
            active: _measurementSystem == MeasurementSystem.imperial,
            onTap: () {
              _markDirty();
              setState(() => _measurementSystem = MeasurementSystem.imperial);
            },
          ),
        ],
      ),
    );
  }
  // ── Validation ────────────────────────────────────────────────────────

  String? _validatePositiveDecimal(String? value) {
    if (value == null || value.isEmpty) return null; // optional fields
    final v = double.tryParse(value);
    if (v == null || v <= 0) return 'Must be a positive number';
    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────

  Widget _buildSaveButton(bool isSaving) {
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
        onPressed: isSaving
            ? null
            : () {
                if (!_formKey.currentState!.validate()) return;
                final existing = widget.profile;
                final updated = UserProfile(
                  // userId is already in the token — we pass it here only
                  // to keep the local entity consistent; backend ignores it
                  userId: existing?.userId ?? '',
                  firstName: _firstNameController.text.trim().isEmpty
                      ? null
                      : _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim().isEmpty
                      ? null
                      : _lastNameController.text.trim(),
                  heightInCm: double.tryParse(_heightController.text),
                  weightInKg: double.tryParse(_weightController.text),
                  measurementSystem: _measurementSystem,
                  birthDate: _birthDate,
                  gender: _gender,
                );
                _updateInProgress = true;
                ref
                    .read(profileOperationsProvider.notifier)
                    .updateProfile(updated);
              },
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'SAVE PROFILE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildDirtyBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have unsaved changes — pull down to discard, or tap Save.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.orange.shade800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  const _MeasurementChip({
    required this.label,
    required this.subtitle,
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
          child: Column(
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: active ? AppColors.white : AppColors.grey,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: active
                      ? AppColors.white.withValues(alpha: 0.8)
                      : AppColors.grey.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
