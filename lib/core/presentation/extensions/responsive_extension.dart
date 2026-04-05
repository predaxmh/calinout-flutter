import 'dart:math';

import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get paddingTop => MediaQuery.of(this).padding.top;
  double get paddingBottom => MediaQuery.of(this).padding.bottom;

  // Usage: height: context.heightPct(0.2) -> 20% of screen height
  double heightPct(double percentage) => screenHeight * percentage;
  double widthPct(double percentage) => screenWidth * percentage;

  double get shortestSide => MediaQuery.of(this).size.shortestSide;

  // Usage: context.spacingSmall
  SizedBox get spacingTiny => SizedBox(height: screenHeight * 0.01); // 1%
  SizedBox get spacingSmall => SizedBox(height: screenHeight * 0.02); // 2%
  SizedBox get spacingMedium => SizedBox(height: screenHeight * 0.04); // 4%
  SizedBox get spacingLarge => SizedBox(height: screenHeight * 0.06); // 6%

  double sp(double size) {
    double scale = shortestSide / 400;
    double newSize = size * scale;
    return max(size * 0.8, min(newSize, size * 1.5));
  }
}
