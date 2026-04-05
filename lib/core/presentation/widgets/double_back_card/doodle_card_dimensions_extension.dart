import 'package:calinout/core/presentation/scaffold/window_size_class.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions.dart';
import 'package:flutter/material.dart';

extension DoodleCardDimensionsExtension on BuildContext {
  DoodleCardDimensions get doodleCardResponsive => DoodleCardDimensions(
    screenWidth: MediaQuery.sizeOf(this).width,
    screenHeight: MediaQuery.sizeOf(this).height,
    sizeClass: windowSizeClass,
  );
}
