import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

class FloatingButtonSpeedDial extends StatelessWidget {
  const FloatingButtonSpeedDial({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 12,
      spaceBetweenChildren: 8,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      activeBackgroundColor: AppColors.primaryDark,
      elevation: 8.0,
      animationCurve: Curves.easeInOut,

      children: [
        SpeedDialChild(
          child: const Icon(Icons.monitor_weight_outlined),
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          label: 'Add Weight',

          labelStyle: AppTextStyles.doodleCardData.copyWith(
            color: AppColors.blue,
          ),
          onTap: () => context.push(Routes.addWeightPage),
        ),
        SpeedDialChild(
          child: const Icon(Icons.restaurant_menu),
          backgroundColor: AppColors.lightDarkYellow,
          foregroundColor: AppColors.white,
          label: 'Add Meal Log',
          labelStyle: AppTextStyles.doodleCardData.copyWith(
            color: AppColors.lightDarkYellow,
          ),
          onTap: () => context.push(Routes.addMealPage),
        ),
        SpeedDialChild(
          child: const Icon(Icons.fastfood_outlined),
          backgroundColor: AppColors.lightDarkRed,
          foregroundColor: AppColors.white,
          label: 'Add Food Log',
          labelStyle: AppTextStyles.doodleCardData.copyWith(
            color: AppColors.lightDarkRed,
          ),
          onTap: () => context.push(Routes.addFoodPage),
        ),
        SpeedDialChild(
          child: const Icon(Icons.category_outlined),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
          label: 'Add Food Type',
          labelStyle: AppTextStyles.doodleCardData.copyWith(
            color: AppColors.success,
          ),
          onTap: () => context.push(Routes.addFoodTypePage),
        ),
        SpeedDialChild(
          child: const Icon(Icons.thunderstorm_outlined),
          backgroundColor: AppColors.secondaryDark,
          foregroundColor: AppColors.white,
          label: 'Add Saved M/F',
          labelStyle: AppTextStyles.doodleCardData.copyWith(
            color: AppColors.secondaryDark,
          ),
          onTap: () => context.push(Routes.quickLogPage),
        ),
      ],
    );
  }
}
