import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/constants/app_strings.dart';
import 'package:calinout/core/constants/assets_paths.dart';
import 'package:calinout/core/presentation/extensions/responsive_extension.dart';
import 'package:calinout/core/presentation/widgets/app_button.dart';
import 'package:calinout/core/presentation/widgets/auth_background.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLandscap =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return AuthBackground(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          SizedBox(
            height: (isLandscap)
                ? context.heightPct(0.05)
                : context.heightPct(0.1),
          ),
          SizedBox(
            height: context.heightPct(0.2),
            child: SvgPicture.asset(
              AssetsPaths.logoTransparent,
              fit: BoxFit.contain,
            ),
          ),
          context.spacingSmall,
          Center(
            // child: Text(AppStrings.slogan, style: AppTextStyles.sloganStyle),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${AppStrings.calorie} ',
                    style: AppTextStyles.sloganStyle.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: '${AppStrings.sloganIn} ',
                    style: AppTextStyles.sloganStyle.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: '${AppStrings.calorie} ',
                    style: AppTextStyles.sloganStyle.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  TextSpan(
                    text: AppStrings.sloganOut,
                    style: AppTextStyles.sloganStyle.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          AppButton(
            label: AppStrings.loginBtnText,
            customColor: AppColors.primary,
            customTextColor: AppColors.secondary,

            onPressed: () => context.push(Routes.login),
          ),
          context.spacingSmall,
          AppButton(
            label: AppStrings.createAccountBtnText,
            customColor: AppColors.secondary,

            customTextColor: AppColors.primaryDark,
            onPressed: () => context.push(Routes.register),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
