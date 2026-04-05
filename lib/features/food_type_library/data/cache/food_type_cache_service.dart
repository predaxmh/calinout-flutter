import 'package:calinout/core/database/hive_box_names.dart';
import 'package:calinout/core/database/hive_service.dart';
import 'package:calinout/features/food_type_library/data/cache/models/food_type_hive.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_type_cache_service.g.dart';

@riverpod
FoodTypeCacheService foodTypeCacheService(Ref ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return FoodTypeCacheService(hiveService);
}

/// Service for managing FoodType cache operations
class FoodTypeCacheService {
  final HiveService _hiveService;

  FoodTypeCacheService(this._hiveService);

  /// Cache duration - adjust based on your needs
  static const Duration cacheMaxAge = Duration(hours: 1);

  Box<FoodTypeHive> get _box =>
      _hiveService.getBox<FoodTypeHive>(HiveBoxNames.foodTypeCache);

  /// Save a single food type to cache
  Future<void> saveFoodType(FoodType foodType) async {
    final hiveModel = FoodTypeHive.fromEntity(foodType);
    await _box.put(foodType.id, hiveModel);
  }

  /// Save multiple food types to cache
  Future<void> saveFoodTypes(List<FoodType> foodTypes) async {
    final Map<int, FoodTypeHive> entries = {
      for (var foodType in foodTypes)
        foodType.id: FoodTypeHive.fromEntity(foodType),
    };
    await _box.putAll(entries);

    // Update cache timestamp
    await _hiveService.updateCacheTimestamp(
      CacheMetadataKeys.foodTypeLastFetch,
    );
  }

  /// Get a single food type from cache
  FoodType? getFoodType(int id) {
    final hiveModel = _box.get(id);
    return hiveModel?.toEntity();
  }

  /// Get all cached food types
  List<FoodType> getAllFoodTypes() {
    return _box.values.map((hiveModel) => hiveModel.toEntity()).toList();
  }

  /// Search cached food types by name
  List<FoodType> searchFoodTypes(String query) {
    if (query.isEmpty) return getAllFoodTypes();

    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((hiveModel) => hiveModel.name.toLowerCase().contains(lowerQuery))
        .map((hiveModel) => hiveModel.toEntity())
        .toList();
  }

  /// Get paginated cached food types
  /// Note: This is for cache only, API handles real pagination
  List<FoodType> getPaginatedFoodTypes({
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) {
    List<FoodType> allItems = searchQuery != null && searchQuery.isNotEmpty
        ? searchFoodTypes(searchQuery)
        : getAllFoodTypes();

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allItems.length) return [];
    if (endIndex >= allItems.length) {
      return allItems.sublist(startIndex);
    }

    return allItems.sublist(startIndex, endIndex);
  }

  /// Delete a food type from cache
  Future<void> deleteFoodType(int id) async {
    await _box.delete(id);
  }

  /// Clear all cached food types
  Future<void> clearCache() async {
    await _box.clear();
  }

  /// Check if cache is stale and needs refresh
  bool isCacheStale() {
    return _hiveService.isCacheStale(
      CacheMetadataKeys.foodTypeLastFetch,
      cacheMaxAge,
    );
  }

  /// Get cache count
  int getCacheCount() => _box.length;

  /// Check if cache is empty
  bool isCacheEmpty() => _box.isEmpty;

  /// Update cached food type after edit
  Future<void> updateFoodType(FoodType foodType) async {
    await saveFoodType(foodType);
  }
}
