import 'package:calinout/core/database/hive_box_names.dart';
import 'package:calinout/core/database/hive_service.dart';
import 'package:calinout/features/nutrient_logs/data/cache/models/food_hive.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_cache_service.g.dart';

@riverpod
FoodCacheService foodCacheService(Ref ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return FoodCacheService(hiveService);
}

class FoodCacheService {
  final HiveService _hiveService;

  FoodCacheService(this._hiveService);

  Box<FoodHive> get _box => _hiveService.getBox(HiveBoxNames.foodCache);

  static const Duration cacheMaxAge = Duration(hours: 1);

  Future<void> saveFood(Food food) async {
    var hiveModel = FoodHive.fromEntity(food);
    await _box.put(food.id, hiveModel);
  }

  Future<void> saveFoods(List<Food> foodList) async {
    final Map<int, FoodHive> entries = {
      for (var food in foodList) food.id: FoodHive.fromEntity(food),
    };
    _box.putAll(entries);
  }

  Food? getFood(int id) {
    var hiveModel = _box.get(id);
    return hiveModel?.toEntity();
  }

  List<Food> getAllFoodList() {
    return _box.values.map((element) => element.toEntity()).toList();
  }

  List<Food> searchFoods(String query) {
    if (query.isEmpty) return getAllFoodList();

    return _box.values
        .where((element) => element.name.toLowerCase().contains(query))
        .map((element) => element.toEntity())
        .toList();
  }

  List<Food> getPaginatedFoods({
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) {
    List<Food> allItems = searchQuery != null && searchQuery.isNotEmpty
        ? searchFoods(searchQuery)
        : getAllFoodList();

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allItems.length) return [];
    if (endIndex >= allItems.length) {
      return allItems.sublist(startIndex);
    }

    return allItems.sublist(startIndex, endIndex);
  }

  Future<void> deleteFood(int id) async {
    await _box.delete(id);
  }

  /// Clear all cached food types
  Future<void> clearCache() async {
    await _box.clear();
  }

  /// Check if cache is stale and needs refresh
  bool isCacheStale() {
    return _hiveService.isCacheStale(
      CacheMetadataKeys.foodLastFetch,
      cacheMaxAge,
    );
  }

  /// Get cache count
  int getCacheCount() => _box.length;

  /// Check if cache is empty
  bool isCacheEmpty() => _box.isEmpty;

  /// Update cached foodafter edit
  Future<void> updateFood(Food food) async {
    await saveFood(food);
  }
}
