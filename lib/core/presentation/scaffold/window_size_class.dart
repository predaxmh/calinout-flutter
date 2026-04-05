import 'package:flutter/Material.dart';

enum WindowSizeClass {
  /// Extra tiny devices (< 320dp) - special handling required
  tiny,

  /// Compact devices (320-599dp) - phones in portrait
  compact,

  /// Medium devices (600-839dp) - tablets in portrait, unfolded foldables
  medium,

  /// Expanded devices (840+dp) - tablets in landscape, desktops
  expanded,
}

class WindowSizeClassDetector {
  WindowSizeClassDetector._();

  /// Get window size class from width
  static WindowSizeClass fromWidth(double width) {
    if (width < 320) return WindowSizeClass.tiny;
    if (width < 600) return WindowSizeClass.compact;
    if (width < 840) return WindowSizeClass.medium;
    return WindowSizeClass.expanded;
  }

  /// Get window size class from context
  static WindowSizeClass fromContext(BuildContext context) {
    //final width = MediaQuery.of(context).size.width; old
    final width = MediaQuery.sizeOf(context).width; // falser
    return fromWidth(width);
  }

  /// Get orientation from context
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }
}

/// Extension for easy access to window size class
extension WindowSizeClassExtension on BuildContext {
  WindowSizeClass get windowSizeClass =>
      WindowSizeClassDetector.fromContext(this);

  Orientation get deviceOrientation =>
      WindowSizeClassDetector.getOrientation(this);

  bool get isLandscape => WindowSizeClassDetector.isLandscape(this);
  bool get isPortrait => WindowSizeClassDetector.isPortrait(this);
}
