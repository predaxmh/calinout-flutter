import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_theme.dart';
import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DoodleCard extends StatelessWidget {
  final DoodleCardTheme theme;

  final double width;

  final VoidCallback? onTap;
  final Widget child;

  const DoodleCard({
    super.key,

    required this.theme,
    required this.width,

    required this.child,
    this.onTap,
  }) : assert(width > 0, 'Width must be positive');

  factory DoodleCard.topBackShape({
    required double width,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.topBackShape,
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.topLeftBackShape({
    required double width,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.topLeftBackShape,
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.bottomRightBackShape({
    required double width,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.bottomRightBackShape,
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.bottomBack({
    required double width,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.bottomBack,
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.tinyBottomBackShape({
    required double width,
    required Widget child,
    Color? backgroundColor,
    Color? surfaceColor,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.tinyBottomBackShape.copyWith(
        backgroundColor: backgroundColor ?? AppColors.secondary,
        surfaceColor: surfaceColor ?? AppColors.white,
      ),
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.listItemShapeFood({
    required double width,
    required Widget child,
    Color? backgroundColor,
    Color? surfaceColor,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.listCardShape.copyWith(
        backgroundColor: backgroundColor ?? AppColors.darkRed,
        surfaceColor: surfaceColor ?? AppColors.lightYellow,
      ),
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.listItemShapeMeal({
    required double width,
    required Widget child,
    Color? backgroundColor,
    Color? surfaceColor,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.listCardShape.copyWith(
        backgroundColor: backgroundColor ?? AppColors.lightDarkYellow,
        surfaceColor: surfaceColor ?? AppColors.lightYellow,
      ),
      onTap: onTap,
      child: child,
    );
  }

  factory DoodleCard.listItemShapeFoodType({
    required double width,
    required Widget child,
    Color? backgroundColor,
    Color? surfaceColor,
    VoidCallback? onTap,
  }) {
    return DoodleCard(
      width: width,
      theme: DoodleCardTheme.listCardShape.copyWith(
        backgroundColor:
            backgroundColor ?? const Color.fromARGB(255, 148, 218, 43),
        surfaceColor: surfaceColor ?? AppColors.lightYellow,
      ),
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    double topOffset = theme.offset.dy > 0 ? theme.offset.dy : 0;
    double bottomOffset = theme.offset.dy < 0 ? -theme.offset.dy : 0;
    double leftOffset = theme.offset.dx > 0 ? theme.offset.dx : 0;
    double rightOffset = theme.offset.dx < 0 ? -theme.offset.dx : 0;

    return MergeSemantics(
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            onTap?.call();
          },
          splashColor: theme.splashColor,
          highlightColor: theme.highlightColor,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: topOffset,
                left: leftOffset,
                bottom: bottomOffset,
                right: rightOffset,

                child: Container(
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius:
                        theme.borderRadius ??
                        BorderRadius.circular(theme.radius),
                    border: Border.all(width: theme.backgroundBorderSize),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: bottomOffset,
                  left: rightOffset,
                  bottom: topOffset,
                  right: leftOffset,
                ),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius:
                        theme.borderRadius ??
                        BorderRadius.circular(theme.radius),
                    border: Border.all(
                      width: theme.surfaceBorderSize,
                      color: AppColors.black,
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
