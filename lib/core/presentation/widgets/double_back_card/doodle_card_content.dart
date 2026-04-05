import 'package:calinout/core/constants/doodle_card_list_item_constants.dart';
import 'package:calinout/core/presentation/extensions/doodle_card_list_item_extension.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_list_item_data.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_list_item_theme.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/core/utils/time_formatter.dart';
import 'package:calinout/core/utils/value_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HorizontalLabelNumber extends StatelessWidget {
  final String label;
  final String number;
  final String unit;
  final Color labelColor;
  final Color numberColor;
  final double labelSize;
  final double numberSize;

  const HorizontalLabelNumber({
    super.key,
    required this.label,
    required this.number,
    this.unit = '', // Optional
    this.labelColor = AppColors.secondary,
    this.numberColor = AppColors.primary,
    this.labelSize = 16,
    this.numberSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: AppTextStyles.doodleCardTitle.copyWith(
                color: labelColor,
                fontSize: labelSize,
              ),
            ),
            SizedBox(width: 5),
            Text(
              number,
              style: AppTextStyles.doodleCardData.copyWith(
                color: numberColor,
                fontSize: numberSize,
              ),
            ),

            if (unit.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                unit,
                style: AppTextStyles.doodleCardTitle.copyWith(
                  color: labelColor,
                  fontSize: labelSize,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VerticalLabelNumber extends StatelessWidget {
  final String label;
  final String number;
  final String unit;
  final Color labelColor;
  final Color numberColor;
  final double labelSize;
  final double numberSize;

  const VerticalLabelNumber({
    super.key,
    required this.label,
    required this.number,
    this.unit = '', // Optional
    this.labelColor = AppColors.secondary,
    this.numberColor = AppColors.primary,
    this.labelSize = 16,
    this.numberSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.doodleCardTitle.copyWith(
                color: labelColor,
                fontSize: labelSize,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    number,
                    style: AppTextStyles.doodleCardData.copyWith(
                      color: numberColor,
                      fontSize: numberSize,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: AppTextStyles.doodleCardTitle.copyWith(
                        color: labelColor,
                        fontSize: labelSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoodleCardListItem extends StatelessWidget {
  final DoodleCardListItemData data;
  final DoodleCardListItemVariant variant;
  final DoodleCardDimensions dimensions;
  final DoodleCardListItemTheme? theme;

  const DoodleCardListItem({
    super.key,
    required this.data,
    required this.dimensions,
    this.variant = DoodleCardListItemVariant.food,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        theme ?? DoodleCardListItemTheme.fromVariant(variant, dimensions);
    final formattedTime = TimeFormatter.formatTime(data.time);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DoodleCardListItemConstants.rowSpacing,
        horizontal: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ─────────────────────────────────────────────────────────
          // ROW 1: Time (left) | Variant Label (right)
          // ─────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (variant == DoodleCardListItemVariant.foodType)
                  ? Text('--:--', style: effectiveTheme.timeStyle)
                  : Text(formattedTime, style: effectiveTheme.timeStyle),
              Text(variant.label, style: effectiveTheme.labelStyle),
            ],
          ),

          // ─────────────────────────────────────────────────────────
          // ROW 2: Name (Weight, Calories)
          // ─────────────────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Name
              Flexible(
                child: Text(
                  data.name,
                  style: effectiveTheme.nameStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '(', style: effectiveTheme.nameStyle),
                    TextSpan(
                      text: ValueFormatter.formatNumber(
                        data.weightValue,
                        decimals: 0,
                      ),
                      style: effectiveTheme.weightValueStyle,
                    ),
                    TextSpan(
                      text: DoodleCardListItemConstants.weightUnit,
                      style: effectiveTheme.weightUnitStyle,
                    ),

                    TextSpan(text: ',', style: effectiveTheme.separatorStyle),

                    // Calorie value + unit
                    TextSpan(
                      text: ValueFormatter.formatNumber(
                        data.calorieValue,
                        decimals: 0,
                      ),
                      style: effectiveTheme.calorieValueStyle,
                    ),
                    TextSpan(
                      text: DoodleCardListItemConstants.calorieUnit,
                      style: effectiveTheme.calorieUnitStyle,
                    ),

                    TextSpan(text: ')', style: effectiveTheme.nameStyle),
                  ],
                ),
              ),
            ],
          ),

          // ─────────────────────────────────────────────────────────
          // ROW 3: Macros (Carb | Fat | Protein)
          // ─────────────────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMacroItem(
                iconPath: DoodleCardListItemConstants.carbIconPath,
                label: DoodleCardListItemConstants.carbLabel,
                value: data.carbValue,
                theme: effectiveTheme,
              ),
              const SizedBox(width: DoodleCardListItemConstants.spacing),
              _buildMacroItem(
                iconPath: DoodleCardListItemConstants.fatIconPath,
                label: DoodleCardListItemConstants.fatLabel,
                value: data.fatValue,
                theme: effectiveTheme,
              ),
              const SizedBox(width: DoodleCardListItemConstants.spacing),
              _buildMacroItem(
                iconPath: DoodleCardListItemConstants.proteinIconPath,
                label: DoodleCardListItemConstants.proteinLabel,
                value: data.proteinValue,
                theme: effectiveTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem({
    required String iconPath,
    required String label,
    required double value,
    required DoodleCardListItemTheme theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconPath,
          width: DoodleCardListItemConstants.macroIconSize,
          height: DoodleCardListItemConstants.macroIconSize,
        ),
        const SizedBox(width: 3),
        Text('$label: ', style: theme.macroLabelStyle),
        Text(
          ValueFormatter.formatNumber(value, decimals: 1),
          style: theme.macroValueStyle,
        ),
        Text(
          DoodleCardListItemConstants.macroUnit,
          style: theme.macroLabelStyle,
        ),
      ],
    );
  }
}
