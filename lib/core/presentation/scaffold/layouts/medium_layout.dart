import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/presentation/scaffold/models/nav_item.dart';
import 'package:calinout/core/presentation/scaffold/widgets/floating_button_speed_dial.dart';
import 'package:calinout/core/presentation/scaffold/widgets/logout_button.dart';
import 'package:calinout/core/presentation/scaffold/widgets/medium_navigation_rail.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MediumLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final FloatingButtonSpeedDial? floatingButtonSpeedDial;
  const MediumLayout({
    super.key,
    required this.navigationShell,
    this.floatingButtonSpeedDial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildMediumAppBar(),
      backgroundColor: AppColors.bgCreamTop,
      body: Row(
        children: [
          MediumNavigationRail(
            currentIndex: navigationShell.currentIndex,
            items: DefaultNavItems.main,
            onDestinationSelected: (int index) {
              if (index == 0) context.go(Routes.home);
              if (index == 1) context.go(Routes.foodTypePage);
              if (index == 2) context.go(Routes.nutritionLogPage);
              if (index == 3) context.go(Routes.weightPage);
              if (index == 4) context.go(Routes.profile);
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
      floatingActionButton: floatingButtonSpeedDial,
    );
  }

  PreferredSizeWidget _buildMediumAppBar() {
    return AppBar(
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: SvgPicture.asset(
          'assets/images/logo_name_transparent.svg',
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      actions: [LogoutButton()],
    );
  }
}
