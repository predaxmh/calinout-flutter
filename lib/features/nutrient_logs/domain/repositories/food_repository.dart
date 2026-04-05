import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';

abstract interface class FoodRepository {
  Future<Result<Food>> create(Food food);
  Future<Result<(List<Food>, bool)>> getAllWithSearch(
    String searchQuery,
    int page,
    int pageSize,
    bool? isTemplate,
    bool? withMealId,
  );
  Future<Result<bool>> delete(int id);
  Future<Result<bool>> update(int id, Food food);
  Future<Result<(List<Food>, bool)>> getAll(int page, int pageSize);
  Future<List<Food>> getCachedOnly();
  Future<Result<List<Food>>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
    bool? showFoodInsideMeal,
  );
  Future<void> clearCache();
  bool isCacheStale();
}
