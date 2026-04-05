import 'package:calinout/core/database/hive_box_names.dart';
import 'package:calinout/core/database/hive_service.dart';
import 'package:calinout/features/nutrient_logs/data/cache/models/meal_hive.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_cache_service.g.dart';

@riverpod
MealCacheService mealCacheService(Ref ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return MealCacheService(hiveService);
}

/// Service for managing Meal cache operations
class MealCacheService {
  final HiveService _hiveService;

  MealCacheService(this._hiveService);

  /// Cache duration - adjust based on your needs
  static const Duration cacheMaxAge = Duration(hours: 1);

  Box<MealHive> get _box =>
      _hiveService.getBox<MealHive>(HiveBoxNames.mealCache);

  /// Save a single meal to cache
  Future<void> saveMeal(Meal meal) async {
    final hiveModel = MealHive.fromEntity(meal);
    await _box.put(meal.id, hiveModel);
  }

  /// Save multiple meals to cache
  Future<void> saveMeals(List<Meal> meals) async {
    final Map<int, MealHive> entries = {
      for (var meal in meals) meal.id: MealHive.fromEntity(meal),
    };
    await _box.putAll(entries);

    // Update cache timestamp
    await _hiveService.updateCacheTimestamp(CacheMetadataKeys.mealLastFetch);
  }

  /// Get a single meal from cache
  Meal? getMeal(int id) {
    final hiveModel = _box.get(id);
    return hiveModel?.toEntity();
  }

  /// Get all cached meals
  List<Meal> getAllMeals() {
    return _box.values.map((hiveModel) => hiveModel.toEntity()).toList();
  }

  /// Search cached meals by name
  List<Meal> searchMeals(String query) {
    if (query.isEmpty) return getAllMeals();

    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((hiveModel) => hiveModel.name.toLowerCase().contains(lowerQuery))
        .map((hiveModel) => hiveModel.toEntity())
        .toList();
  }

  /// Get paginated cached meals
  /// Note: This is for cache only, API handles real pagination
  List<Meal> getPaginatedMeals({
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) {
    List<Meal> allItems = searchQuery != null && searchQuery.isNotEmpty
        ? searchMeals(searchQuery)
        : getAllMeals();

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allItems.length) return [];
    if (endIndex >= allItems.length) {
      return allItems.sublist(startIndex);
    }

    return allItems.sublist(startIndex, endIndex);
  }

  /// Delete a meal from cache
  Future<void> deleteMeal(int id) async {
    await _box.delete(id);
  }

  /// Clear all cached meals
  Future<void> clearCache() async {
    await _box.clear();
  }

  /// Check if cache is stale and needs refresh
  bool isCacheStale() {
    return _hiveService.isCacheStale(
      CacheMetadataKeys.mealLastFetch,
      cacheMaxAge,
    );
  }

  /// Get cache count
  int getCacheCount() => _box.length;

  /// Check if cache is empty
  bool isCacheEmpty() => _box.isEmpty;

  /// Update cached meal after edit
  Future<void> updateMeal(Meal meal) async {
    await saveMeal(meal);
  }
}
