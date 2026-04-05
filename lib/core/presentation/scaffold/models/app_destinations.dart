import 'package:flutter/material.dart';

class AppDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

const List<AppDestination> appDestinations = [
  AppDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  AppDestination(
    label: 'Foods',
    icon: Icons.restaurant_menu_outlined,
    activeIcon: Icons.restaurant_menu,
  ),
  AppDestination(
    label: 'Daily Log',
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
  ),
  AppDestination(
    label: 'Weight',
    icon: Icons.monitor_weight_outlined,
    activeIcon: Icons.monitor_weight,
  ),
  AppDestination(
    label: 'Profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  ),
];
