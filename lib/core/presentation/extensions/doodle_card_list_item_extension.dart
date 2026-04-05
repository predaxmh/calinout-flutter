enum DoodleCardListItemVariant { food, meal, foodType }

extension DoodleCardListItemVariantExtension on DoodleCardListItemVariant {
  /// Display label for the variant
  String get label {
    switch (this) {
      case DoodleCardListItemVariant.food:
        return 'Food';
      case DoodleCardListItemVariant.meal:
        return 'Meal';
      case DoodleCardListItemVariant.foodType:
        return 'foodType';
    }
  }
}
