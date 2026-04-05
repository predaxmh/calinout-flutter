import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/Material.dart';

class DoodleCardTheme {
  final Color surfaceColor;
  final Color backgroundColor;

  final double backgroundBorderSize;
  final double surfaceBorderSize;

  final Offset offset;
  final double radius;
  final EdgeInsets padding;

  final BorderRadius? borderRadius;

  final double elevation;
  final Color splashColor;
  final Color highlightColor;

  const DoodleCardTheme({
    this.surfaceColor = AppColors.white,
    this.backgroundColor = AppColors.secondary,
    this.borderRadius,
    this.backgroundBorderSize = 2,
    this.surfaceBorderSize = 3,

    this.offset = const Offset(5, 5),
    this.radius = 30,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),

    this.elevation = 6,
    this.splashColor = AppColors.secondary,
    this.highlightColor = const Color(0x11000000),
  });

  /// TOP CENTER (main card)

  static const DoodleCardTheme topBackShape = DoodleCardTheme(
    offset: Offset(0, -6),
    radius: 30,
    elevation: 8,
  );

  /// TOP LEFT / RIGHT (side cards)

  static const DoodleCardTheme topLeftBackShape = DoodleCardTheme(
    offset: Offset(-8, -6),
    radius: 20,
    elevation: 6,
    backgroundColor: AppColors.primary,
  );

  /// BOTTOM RIGHT (angled small emphasis)

  static const DoodleCardTheme bottomRightBackShape = DoodleCardTheme(
    offset: Offset(6, 8),
    radius: 12,
    elevation: 4,
    backgroundColor: AppColors.primary,
  );

  /// BOTTOM LONG PILL

  static const DoodleCardTheme bottomBack = DoodleCardTheme(
    offset: Offset(0, 10),
    radius: 25,
    elevation: 4,
    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
  );

  /// TINY BOTTOM PILL

  static const DoodleCardTheme tinyBottomBackShape = DoodleCardTheme(
    offset: Offset(0, 5),
    radius: 25,
    elevation: 3,
    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
  );

  static const DoodleCardTheme listCardShape = DoodleCardTheme(
    offset: Offset(5, 7),
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(35),
      bottomRight: Radius.circular(35),
      topLeft: Radius.elliptical(25, 25),
      bottomLeft: Radius.elliptical(25, 25),
    ),
    radius: 40,
    elevation: 3,
    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
    backgroundBorderSize: 2,
    surfaceBorderSize: 3,
  );

  DoodleCardTheme copyWith({
    Color? surfaceColor,
    Color? backgroundColor,
    Offset? offset,
    double? backgroundBorderSize,
    double? surfaceBorderSize,
    double? radius,
    EdgeInsets? padding,
    double? elevation,
    BorderSide? borderSide,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return DoodleCardTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      backgroundBorderSize: backgroundBorderSize ?? this.backgroundBorderSize,
      offset: offset ?? this.offset,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceBorderSize: surfaceBorderSize ?? this.surfaceBorderSize,
      radius: radius ?? this.radius,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }
}
