import 'package:calinout/core/presentation/scaffold/models/nav_item.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CompactBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const CompactBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: bottomPadding > 10 ? 80 : 70,

      decoration: BoxDecoration(
        color: AppColors.bgCreamTop,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: List.generate(
            items.length,
            (index) => FittedBox(
              fit: BoxFit.scaleDown,
              child: _CompactNavButton(
                item: items[index],

                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactNavButton extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.secondary : AppColors.primaryDark;

    return Material(
      color: AppColors.bgCreamTop,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: AppColors.lightDarkYellow,
        child: Semantics(
          label: item.label,
          selected: isSelected,
          button: true,
          enabled: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: color,
                  size: 26,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
