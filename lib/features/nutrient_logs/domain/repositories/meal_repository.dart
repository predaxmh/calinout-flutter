import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';

abstract class MealRepository {
  Future<Result<Meal>> create(Meal meal);
  Future<Result<(List<Meal>, bool)>> getAllWithSearch(
    String searchQuery,
    int page,
    int pageSize,
    bool? isTemplate,
  );
  Future<Result<bool>> delete(int id);
  Future<Result<bool>> update(int id, Meal meal);
  Future<Result<List<Meal>>> getAll(int page, int pageSize);
  Future<List<Meal>> getCachedOnly();

  Future<Result<List<Meal>>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
  );
  Future<void> clearCache();
  bool isCacheStale();
}
