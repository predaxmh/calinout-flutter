import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class HomeExtraDataBar extends StatelessWidget {
  final bool isDigestiveCleared;
  final bool isCheatDay;
  final VoidCallback onToggleDigestive;
  final VoidCallback onToggleCheatDay;
  final VoidCallback onAddNote;

  const HomeExtraDataBar({
    super.key,
    required this.isDigestiveCleared,
    required this.isCheatDay,
    required this.onToggleDigestive,
    required this.onToggleCheatDay,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCreamTop,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggles
          _ActionToggle(
            label: 'Cleared ',
            icon: Icons.check_circle_outline,
            isActive: isDigestiveCleared,
            activeColor: AppColors.secondary,
            onTap: onToggleDigestive,
          ),
          _ActionToggle(
            label: 'Cheat Day',
            icon: Icons.local_pizza_outlined,
            isActive: isCheatDay,
            activeColor: AppColors.secondary,
            onTap: onToggleCheatDay,
          ),

          IconButton.filledTonal(
            onPressed: onAddNote,
            icon: const Icon(Icons.edit_note),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
              foregroundColor: AppColors.primary,
            ),
            tooltip: 'Daily Note',
          ),

          // Note Button
        ],
      ),
    );
  }
}

class _ActionToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionToggle({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : AppColors.grey.withValues(alpha: 0.2),
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : AppColors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isActive ? activeColor : AppColors.primaryDark,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
