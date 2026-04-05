import 'package:calinout/core/presentation/scaffold/models/nav_item.dart';
import 'package:calinout/core/presentation/scaffold/widgets/compact_bottom_bar.dart';
import 'package:calinout/core/presentation/scaffold/widgets/floating_button_speed_dial.dart';
import 'package:calinout/core/presentation/scaffold/widgets/logout_button.dart';
import 'package:calinout/core/theme/app_colors.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CompactLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final FloatingButtonSpeedDial? floatingButtonSpeedDial;
  const CompactLayout({
    super.key,
    required this.navigationShell,
    this.floatingButtonSpeedDial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCompactAppBar(),
      backgroundColor: AppColors.bgCreamTop,
      body: navigationShell, // The shell injects your HomePageScreen here
      bottomNavigationBar: CompactBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: DefaultNavItems.main,
      ),

      floatingActionButton: floatingButtonSpeedDial,
    );
  }

  PreferredSizeWidget _buildCompactAppBar() {
    return AppBar(
      centerTitle: true,
      title: SvgPicture.asset(
        'assets/images/logo_name_transparent.svg',
        height: 32,
        fit: BoxFit.contain,
      ),

      actions: const [SizedBox(width: 48), LogoutButton()],
    );
  }
}
