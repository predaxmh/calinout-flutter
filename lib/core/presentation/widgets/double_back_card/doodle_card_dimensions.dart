import 'dart:math';

import 'package:calinout/core/presentation/scaffold/window_size_class.dart';

class DoodleCardDimensions {
  final double screenWidth;
  final double screenHeight;
  final WindowSizeClass sizeClass;

  DoodleCardDimensions({
    required this.screenWidth,
    required this.screenHeight,
    required this.sizeClass,
  });

  // ---------------------------------------------------------------------------
  // DIMENSIONS (ALL 12 GETTERS)
  // ---------------------------------------------------------------------------
  double get topBackWidth => _w(
    tiny: [0.34, 120],
    compact: [0.37, 190],
    medium: [0.28, 210],
    expanded: [0.245, 260],
  );

  // Top Left (Goal Card)
  // Mobile: ~24% of screen | Maxes out at 180px
  double get topLeftBackWidth => _w(
    tiny: [0.23, 80],
    compact: [0.24, 120],
    medium: [0.19, 140],
    expanded: [0.175, 180],
  );

  // Bottom Right (Basal/Base Card)
  // Same proportions as Top Left
  double get bottomRightBackWidth => _w(
    tiny: [0.23, 80],
    compact: [0.24, 120],
    medium: [0.19, 140],
    expanded: [0.175, 180],
  );

  // Bottom Wide Card (Maintenance)
  // Mobile: ~39% of screen | Maxes out at 360px
  double get bottomBackWidth => _w(
    tiny: [0.40, 120],
    compact: [0.39, 200],
    medium: [0.31, 240],
    expanded: [0.305, 320],
  );

  // Macro Pills (Tiny Cards)
  // Mobile: ~30% of screen | Maxes out at 240px
  double get tinyBackWidth => _w(
    tiny: [0.30, 100],
    compact: [0.30, 153],
    medium: [0.24, 177],
    expanded: [0.22, 240],
  );

  // List Item Card (Food Entry)
  // Takes up almost the full width, but capped for readability on huge screens
  double get listItemCardWidth => _w(
    tiny: [0.92, 300],
    compact: [0.94, 490],
    medium: [0.85, 600],
    expanded: [0.72, 860], // On 4k screens, don't stretch the card too wide
  );

  // ---------------------------------------------------------------------------
  // 2. THE ENGINE (Clean & Simple)
  // ---------------------------------------------------------------------------

  /// Calculates width based on [availableWidth] percentage.
  ///
  /// [maxPixel] acts as the "Barrier". Once the calculated percentage exceeds
  /// this value, the width freezes.
  double _w({
    required List<double> tiny,
    required List<double> compact,
    required List<double> medium,
    required List<double> expanded,
  }) {
    // 1. Select the percentage rule for the current breakpoint
    double targetPercent;
    switch (sizeClass) {
      case WindowSizeClass.tiny:
        targetPercent = tiny[0];
        final double fluidWidth = screenWidth * targetPercent;
        return min(fluidWidth, tiny[1]);

      case WindowSizeClass.compact:
        targetPercent = compact[0];
        final double fluidWidth = screenWidth * targetPercent;
        return min(fluidWidth, compact[1]);

      case WindowSizeClass.medium:
        targetPercent = medium[0];
        final double fluidWidth = screenWidth * targetPercent;
        return min(fluidWidth, medium[1]);

      case WindowSizeClass.expanded:
        targetPercent = expanded[0];
        final double fluidWidth = screenWidth * targetPercent;
        return min(fluidWidth, expanded[1]);
    }
  }

  /// The Core Interpolator with Barrier
  double _gate(double startW, double endW, double minH, double maxH) {
    // 1. Barrier Check: If wider than the gate, return max height immediately
    if (screenWidth >= endW) return maxH;

    // 2. Safety Check: If narrower than start, return min height
    if (screenWidth <= startW) return minH;

    // 3. Interpolate (Lerp)
    final ratio = (screenWidth - startW) / (endW - startW);
    return (minH + (ratio * (maxH - minH))).roundToDouble();
  }

  // ---------------------------------------------------------------------------
  // 4. TEXT SIZES (Interpolated + Scaled for Tiny)
  // ---------------------------------------------------------------------------

  // Headers & Big Numbers
  double get topBackLabelSize => _t(14, 28, 30, 32, 38, 40);
  double get topBackNumberSize => _t(24, 36, 34, 36, 38, 42);

  // Standard Card Content
  double get cardLabelSize => _t(14, 22, 22, 24, 30, 34);
  double get cardNumberSize => _t(16, 24, 22, 26, 32, 36);
  double get cardLabelAndTimeSize => _t(12, 14, 16, 18, 18, 18);

  // List Items
  double get listItemNameSize => _t(16, 18, 20, 22, 24, 28);
  double get numericLargeValueSize => _t(16, 18, 20, 22, 24, 28);
  double get unitsSize => _t(12, 16, 18, 20, 22, 22);

  // Macro Pills
  double get macroValueSize => _t(12, 14, 16, 18, 20, 20);
  double get macroLabelSize => _t(12, 14, 16, 18, 20, 20);

  // Section Headers
  double get todayTextSize => _t(18, 26, 26, 28, 30, 32);

  // ---------------------------------------------------------------------------
  // 5. SPACING & GAPS (Fluid)
  // ---------------------------------------------------------------------------

  /// The outer padding of the screen (EdgeInsets)
  double get screenPadding => _gap(
    tiny: 6, // Tight on tiny screens
    compactMin: 8,
    compactMax: 16,
    mediumMin: 20,
    mediumMax: 32,
    expandedMin: 30,
    expandedMax: 48,
  );

  double get cardGapHorizontal => _gap(
    tiny: 6,
    compactMin: 5,
    compactMax: 15,
    mediumMin: 18,
    mediumMax: 28,
    expandedMin: 28,
    expandedMax: 38,
  );

  double get cardGapVertical => _gap(
    tiny: 8,
    compactMin: 10,
    compactMax: 20,
    mediumMin: 20,
    mediumMax: 26,
    expandedMin: 26,
    expandedMax: 32,
  );

  // ---------------------------------------------------------------------------
  // 6. ALIGNMENT & HELPERS
  // ---------------------------------------------------------------------------

  // space between the word today and view full list which is a size box wrap the header
  double get listHeaderWidth => listItemCardWidth;

  // this is the line between the top section and the cardlist
  double get dividerWidth => tinyBackWidth * 2.5;

  // ---------------------------------------------------------------------------
  // 7. ENGINES (Text & Gaps)
  // ---------------------------------------------------------------------------

  /// Text Size Engine
  /// [cMin/cMax] = Compact Range
  /// [mMin/mMax] = Medium Range
  /// [eMin/eMax] = Expanded Range
  /// Tiny is automatically calculated as 90% of cMin to save manual work.
  double _t(
    double cMin,
    double cMax,
    double mMin,
    double mMax,
    double eMin,
    double eMax,
  ) {
    switch (sizeClass) {
      case WindowSizeClass.tiny:
        return cMin * 0.90; // Automatically 10% smaller than compact start
      case WindowSizeClass.compact:
        // Text grows until 470dp then caps, just like your original design
        return _gate(320, 470, cMin, cMax);
      case WindowSizeClass.medium:
        return _gate(600, 839, mMin, mMax);
      case WindowSizeClass.expanded:
        return _gate(840, 1200, eMin, eMax);
    }
  }

  /// Gap/Padding Engine
  /// Simpler than text, just standard fluid growth
  double _gap({
    required double tiny,
    required double compactMin,
    required double compactMax,
    required double mediumMin,
    required double mediumMax,
    required double expandedMin,
    required double expandedMax,
  }) {
    switch (sizeClass) {
      case WindowSizeClass.tiny:
        return tiny;
      case WindowSizeClass.compact:
        return _gate(320, 600, compactMin, compactMax);
      case WindowSizeClass.medium:
        return _gate(600, 840, mediumMin, mediumMax);
      case WindowSizeClass.expanded:
        return _gate(840, 1200, expandedMin, expandedMax);
    }
  }
}
