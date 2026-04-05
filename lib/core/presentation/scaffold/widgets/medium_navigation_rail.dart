import 'package:calinout/core/presentation/scaffold/models/nav_item.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MediumNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool extended;

  const MediumNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.white;
    final effectiveSelectedColor = selectedColor ?? AppColors.secondary;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.primaryDark;

    return NavigationRail(
      scrollable: true,

      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      backgroundColor: effectiveBackgroundColor,
      selectedIconTheme: IconThemeData(color: effectiveSelectedColor, size: 28),
      unselectedIconTheme: IconThemeData(
        color: effectiveUnselectedColor,
        size: 26,
      ),
      selectedLabelTextStyle: TextStyle(
        color: effectiveSelectedColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: effectiveUnselectedColor,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.activeIcon),

          label: Text(item.label),
          padding: const EdgeInsets.symmetric(vertical: 4),
        );
      }).toList(),
    );
  }
}
