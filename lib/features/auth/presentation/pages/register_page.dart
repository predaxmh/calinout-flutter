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
import 'package:calinout/features/auth/presentation/logic/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(registerViewModelProvider);

    ref.listen(registerViewModelProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          context.showError(message);
        },
        orElse: () {},
      );
    });

    return AuthBackground(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.heightPct(0.04)),

                Center(
                  child: SizedBox(
                    height: 100,
                    child: SvgPicture.asset(
                      AssetsPaths.logoTransparent,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                context.spacingMedium,

                Center(
                  child: CustomMulitColorText(
                    textColorList: [
                      {'Regis': AppColors.primary},
                      {'ter': AppColors.secondary},
                    ],
                    textStyle: AppTextStyles.headerLarge.copyWith(
                      fontSize: context.sp(26),
                    ),
                  ),
                ),

                context.spacingMedium,

                // 2. Inputs (3 Fields)
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

                context.spacingSmall,

                AppTextField(
                  controller: _confirmController,
                  label: AppStrings.confirmPassword,
                  icon: Icons.lock_reset, // Distinct icon for confirm
                  obscureText: true,
                ),

                context.spacingLarge,

                uiState.maybeWhen(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  orElse: () => AppButton(
                    label: AppStrings.registerBtnText,
                    type: ButtonType.primary,
                    customColor:
                        AppColors.secondary, // Different color for Register
                    customTextColor: AppColors.primaryDark,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ref
                          .read(registerViewModelProvider.notifier)
                          .register(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            confirmPassword: _confirmController.text,
                          );
                    },
                  ),
                ),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    context.go(Routes.login);
                  },
                  child: Text(
                    AppStrings.alreadyHaveAccount,

                    style: AppTextStyles.textButtonTextStyle,
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
