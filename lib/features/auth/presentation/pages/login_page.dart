import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/constants/app_strings.dart';
import 'package:calinout/core/constants/assets_paths.dart';
import 'package:calinout/core/presentation/extensions/responsive_extension.dart';
import 'package:calinout/core/presentation/extensions/scack_bar_msg_extension.dart';
import 'package:calinout/core/presentation/widgets/app_button.dart';
import 'package:calinout/core/presentation/widgets/app_text_field.dart';
import 'package:calinout/core/presentation/widgets/auth_background.dart';
import 'package:calinout/core/presentation/widgets/custom_multi_color_text.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/features/auth/presentation/logic/auth_ui_state.dart';
import 'package:calinout/features/auth/presentation/logic/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(loginViewModelProvider);

    ref.listen(loginViewModelProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          context.showError(message);
        },
        success: () => context.showSuccess('you Have Successfully login'),
        orElse: () {},
      );
    });

    return AuthBackground(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // hasScrollBody: false tells it: "I am not an infinite list."
          // It effectively says: "Layout my child. If it fits, stretch it to fill the viewport.
          // If it doesn't fit, let it scroll normally."
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.heightPct(0.05)),

                Center(
                  child: SizedBox(
                    height: 100,
                    child: SvgPicture.asset(AssetsPaths.logoTransparent),
                  ),
                ),

                context.spacingLarge,

                // here we make the fisrt two letters in color and the other in another
                Center(
                  child: CustomMulitColorText(
                    textColorList: [
                      {'Log': AppColors.primary},
                      {'in': AppColors.secondary},
                    ],
                    textStyle: AppTextStyles.headerLarge.copyWith(
                      fontSize: context.sp(26),
                    ),
                  ),
                ),

                context.spacingMedium,

                AppTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                ),

                context.spacingSmall,

                AppTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                context.spacingLarge,

                uiState.maybeWhen(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  orElse: () => AppButton(
                    label: AppStrings.loginBtnText,
                    type: ButtonType.primary,
                    customTextColor: AppColors.secondary,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ref
                          .read(loginViewModelProvider.notifier)
                          .login(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                    },
                  ),
                ),

                const Spacer(),

                TextButton(
                  onPressed: () => context.push(Routes.register),
                  child: Text(
                    AppStrings.dontHaveAccount,
                    style: AppTextStyles.textButtonTextStyle.copyWith(
                      fontSize: context.sp(15),
                    ),
                  ),
                ),

                context.spacingSmall,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
