import 'package:calinout/core/presentation/extensions/responsive_extension.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.textFieldLableStyle.copyWith(
            fontSize: context.sp(16),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTextStyles.textFieldTextStyle.copyWith(
              fontSize: context.sp(14),
            ),
            cursorColor: AppColors.secondary,
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.secondaryDark)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),

                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
