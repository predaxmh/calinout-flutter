import 'package:calinout/core/presentation/scaffold/widgets/floating_button_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'layouts/compact_layout.dart';
import 'layouts/medium_layout.dart';
import 'window_size_class.dart';

class AdaptiveScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sizeClass = WindowSizeClassDetector.fromWidth(width);

        final isCompactLayout =
            sizeClass == WindowSizeClass.tiny ||
            sizeClass == WindowSizeClass.compact;
        final floatingButtonSpeedDial = FloatingButtonSpeedDial();
        if (isCompactLayout) {
          return CompactLayout(
            navigationShell: navigationShell,
            floatingButtonSpeedDial: floatingButtonSpeedDial,
          );
        } else {
          return MediumLayout(
            navigationShell: navigationShell,
            floatingButtonSpeedDial: floatingButtonSpeedDial,
          );
        }
      },
    );
  }
}
