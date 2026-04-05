import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get headerLarge => GoogleFonts.notoSansJp(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 1.3,
  );

  static TextStyle get sloganStyle => GoogleFonts.notoSansJp(
    fontSize: 15,
    fontWeight: FontWeight.w900,

    color: Colors.white,
    letterSpacing: 1.3,
  );

  static TextStyle get headerMedium => GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
    letterSpacing: 1,
  );

  static TextStyle get bodyMedium =>
      GoogleFonts.exo2(fontSize: 14, color: AppColors.grey, height: 1.4);

  static TextStyle get doodleCardData => GoogleFonts.fredoka(
    fontSize: 22,
    color: AppColors.primary,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
  );

  static TextStyle get doodleCardTitle => GoogleFonts.fredoka(
    fontSize: 12,
    color: AppColors.secondary,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  static TextStyle get todayText => GoogleFonts.fredoka(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  // 3. Button Text
  static TextStyle get buttonText => GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: AppColors.white,
  );

  static TextStyle get textButtonTextStyle => GoogleFonts.notoSansJp(
    color: Colors.white.withValues(alpha: 0.8),
    decoration: TextDecoration.underline,
    decorationColor: Colors.white.withValues(alpha: 0.8),
    fontSize: 15,
  );

  //text field style
  static TextStyle get textFieldLableStyle => GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 3,
    color: AppColors.primary,
  );

  static TextStyle get erroTextStyle => GoogleFonts.exo2(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get textFieldTextStyle => GoogleFonts.notoSansJp(
    fontSize: 14,
    fontWeight: FontWeight.bold,

    color: AppColors.white,
  );

  static TextStyle get snackBarTextStyle => GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );
}
