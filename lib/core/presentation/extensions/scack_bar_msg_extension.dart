import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

extension SnackBarMsgExtension on BuildContext {
  void showError(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar() // Removes old snackbars instantly
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.snackBarTextStyle.copyWith(fontSize: 18),
          ),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.snackBarTextStyle.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
