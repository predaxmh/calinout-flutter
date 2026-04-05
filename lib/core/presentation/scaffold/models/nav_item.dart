import 'package:flutter/material.dart';

/// Navigation item model for all navigation components
@immutable
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  final String? route; // Optional route path

  const NavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,

    this.route,
  }) : activeIcon = activeIcon ?? icon;

  NavItem copyWith({
    IconData? icon,
    IconData? activeIcon,
    String? label,

    String? route,
  }) {
    return NavItem(
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,

      route: route ?? this.route,
    );
  }
}

// Default navigation items
class DefaultNavItems {
  DefaultNavItems._();

  static const List<NavItem> main = [
    NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    NavItem(
      label: 'Foods',
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
    ),
    NavItem(
      label: 'Nutrition Log',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(
      label: 'Weight',
      icon: Icons.monitor_weight_outlined,
      activeIcon: Icons.monitor_weight,
    ),
    NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];
}
