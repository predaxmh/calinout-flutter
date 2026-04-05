import 'package:calinout/core/presentation/extensions/doodle_card_list_item_extension.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class DoodleCardListItemTheme {
  // Top row styles
  final TextStyle timeStyle;
  final TextStyle labelStyle; // "Food", "Meal", etc.

  // Middle row styles (name + weight + calories)
  final TextStyle nameStyle;
  final TextStyle weightValueStyle;
  final TextStyle weightUnitStyle;
  final TextStyle calorieValueStyle;
  final TextStyle calorieUnitStyle;
  final TextStyle separatorStyle;

  // Bottom row styles (macros)
  final TextStyle macroLabelStyle;
  final TextStyle macroValueStyle;

  const DoodleCardListItemTheme({
    required this.timeStyle,
    required this.labelStyle,
    required this.nameStyle,
    required this.weightValueStyle,
    required this.weightUnitStyle,
    required this.calorieValueStyle,
    required this.calorieUnitStyle,
    required this.separatorStyle,
    required this.macroLabelStyle,
    required this.macroValueStyle,
  });

  /// Default theme for Food variant
  factory DoodleCardListItemTheme.food(DoodleCardDimensions dimension) {
    return DoodleCardListItemTheme(
      timeStyle: GoogleFonts.fredoka(
        fontSize: dimension.cardLabelAndTimeSize,
        color: AppColors.black,
        fontWeight: FontWeight.w900,
      ),
      labelStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.cardLabelAndTimeSize,
        color: AppColors.darkRed,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      nameStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.listItemNameSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkRed,
        letterSpacing: 2,
      ),
      weightValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.numericLargeValueSize,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
        letterSpacing: 1,
      ),
      weightUnitStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkRed,
        letterSpacing: 1,
      ),
      calorieValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.numericLargeValueSize,
        fontWeight: FontWeight.bold,
        color: AppColors.lightDarkRed,
        letterSpacing: 1,
      ),
      calorieUnitStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkRed,
        letterSpacing: 1,
      ),
      separatorStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      macroLabelStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.macroLabelSize,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      macroValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.macroValueSize,
        fontWeight: FontWeight.w500,
        color: AppColors.lightDarkRed,
      ),
    );
  }

  factory DoodleCardListItemTheme.meal(DoodleCardDimensions dimension) {
    return DoodleCardListItemTheme(
      timeStyle: GoogleFonts.fredoka(
        fontSize: dimension.cardLabelAndTimeSize,
        color: AppColors.black,
        fontWeight: FontWeight.w900,
      ),
      labelStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.cardLabelAndTimeSize,
        color: AppColors.lightDarkYellow,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      nameStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.listItemNameSize,
        fontWeight: FontWeight.bold,
        color: AppColors.lightDarkYellow,
        letterSpacing: 2,
      ),
      weightValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.numericLargeValueSize,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
        letterSpacing: 1,
      ),
      weightUnitStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.lightDarkYellow,
        letterSpacing: 1,
      ),
      calorieValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.numericLargeValueSize,
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
        letterSpacing: 1,
      ),
      calorieUnitStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.lightDarkYellow,
        letterSpacing: 1,
      ),
      separatorStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      macroLabelStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.macroLabelSize,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      macroValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.macroValueSize,
        fontWeight: FontWeight.w500,
        color: AppColors.lightDarkRed,
      ),
    );
  }

  factory DoodleCardListItemTheme.foodType(DoodleCardDimensions dimension) {
    return DoodleCardListItemTheme(
      timeStyle: GoogleFonts.fredoka(
        fontSize: dimension.cardLabelAndTimeSize,
        color: AppColors.black,
        fontWeight: FontWeight.w900,
      ),
      labelStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.cardLabelAndTimeSize,
        color: AppColors.success,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      nameStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.listItemNameSize,
        fontWeight: FontWeight.bold,
        color: AppColors.green,
        letterSpacing: 2,
      ),
      weightValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.numericLargeValueSize,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 16, 111, 9),
        letterSpacing: 1,
      ),
      weightUnitStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 28, 28, 27),
        letterSpacing: 1,
      ),
      calorieValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.numericLargeValueSize,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 119, 3, 61),
        letterSpacing: 1,
      ),
      calorieUnitStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 28, 28, 27),
        letterSpacing: 1,
      ),
      separatorStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.unitsSize,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      macroLabelStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.macroLabelSize,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      macroValueStyle: GoogleFonts.archivoBlack(
        fontSize: dimension.macroValueSize,
        fontWeight: FontWeight.w500,
        color: AppColors.lightDarkRed,
      ),
    );
  }

  /// Get theme based on variant
  factory DoodleCardListItemTheme.fromVariant(
    DoodleCardListItemVariant variant,
    DoodleCardDimensions dimension,
  ) {
    switch (variant) {
      case DoodleCardListItemVariant.food:
        return DoodleCardListItemTheme.food(dimension);
      case DoodleCardListItemVariant.meal:
        return DoodleCardListItemTheme.meal(dimension);
      case DoodleCardListItemVariant.foodType:
        return DoodleCardListItemTheme.foodType(dimension);
    }
  }

  DoodleCardListItemTheme copyWith({
    TextStyle? timeStyle,
    TextStyle? labelStyle,
    TextStyle? nameStyle,
    TextStyle? weightValueStyle,
    TextStyle? weightUnitStyle,
    TextStyle? calorieValueStyle,
    TextStyle? calorieUnitStyle,
    TextStyle? separatorStyle,
    TextStyle? macroLabelStyle,
    TextStyle? macroValueStyle,
  }) {
    return DoodleCardListItemTheme(
      timeStyle: timeStyle ?? this.timeStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      nameStyle: nameStyle ?? this.nameStyle,
      weightValueStyle: weightValueStyle ?? this.weightValueStyle,
      weightUnitStyle: weightUnitStyle ?? this.weightUnitStyle,
      calorieValueStyle: calorieValueStyle ?? this.calorieValueStyle,
      calorieUnitStyle: calorieUnitStyle ?? this.calorieUnitStyle,
      separatorStyle: separatorStyle ?? this.separatorStyle,
      macroLabelStyle: macroLabelStyle ?? this.macroLabelStyle,
      macroValueStyle: macroValueStyle ?? this.macroValueStyle,
    );
  }
}
