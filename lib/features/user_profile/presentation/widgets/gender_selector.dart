import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final Gender? selected;
  final ValueChanged<Gender?> onChanged;

  const GenderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GenderChip(
          label: 'Male',
          icon: Icons.male,
          active: selected == Gender.male,
          onTap: () => onChanged(selected == Gender.male ? null : Gender.male),
        ),
        const SizedBox(width: 8),
        _GenderChip(
          label: 'Female',
          icon: Icons.female,
          active: selected == Gender.female,
          onTap: () =>
              onChanged(selected == Gender.female ? null : Gender.female),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _GenderChip({
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
            color: active ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
              width: active ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? AppColors.white : AppColors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: active ? AppColors.white : AppColors.grey,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
