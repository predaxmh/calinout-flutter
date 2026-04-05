import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/features/auth/presentation/logic/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LogoutButtonStyle { iconButton, listTile }

class LogoutButton extends ConsumerWidget {
  final LogoutButtonStyle style;
  final bool skipConfirmation;

  const LogoutButton({
    super.key,
    this.style = LogoutButtonStyle.iconButton,
    this.skipConfirmation = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(authControllerProvider)
        .maybeWhen(loading: () => true, orElse: () => false);

    void onTap() {
      if (skipConfirmation) {
        ref.read(authControllerProvider.notifier).logout();
      } else {
        _confirmLogout(context, ref);
      }
    }

    return switch (style) {
      // ── Icon button — AppBar usage ───────────────────────────────────
      LogoutButtonStyle.iconButton => IconButton(
        tooltip: 'Logout',
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : const Icon(Icons.logout, color: AppColors.error),
      ),

      // ── List tile — drawer / settings menu usage ─────────────────────
      LogoutButtonStyle.listTile => ListTile(
        leading: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : const Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Logout',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: isLoading ? null : onTap,
      ),
    };
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will be returned to the welcome screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
