import 'package:calinout/core/presentation/extensions/responsive_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum ButtonType { primary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonType type;
  final Color? customColor;
  final Color? customTextColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.customColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = customColor ?? AppColors.primary;

    final defaultTextColor = type == ButtonType.primary
        ? Colors.black
        : baseColor;

    final textColor = customTextColor ?? defaultTextColor;

    final isOutlined = type == ButtonType.outlined;
    final isGhost = type == ButtonType.ghost;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined || isGhost
              ? Colors.transparent
              : baseColor.withValues(alpha: 0.2),
          foregroundColor: baseColor,
          elevation: isOutlined || isGhost ? 0 : 10,
          shadowColor: isGhost ? null : baseColor.withValues(alpha: 0.5),

          side: isGhost
              ? BorderSide.none
              : BorderSide(color: baseColor, width: 2),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Cyber sharp corners
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyles.buttonText.copyWith(
            color: textColor,
            fontSize: context.sp(15),
          ),
        ),
      ),
    );
  }
}
