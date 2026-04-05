import 'package:calinout/core/database/hive_box_names.dart';
import 'package:calinout/features/food_type_library/data/cache/models/food_type_hive.dart';
import 'package:calinout/features/home_manager/data/cache/models/daily_log_hive.dart';
import 'package:calinout/features/nutrient_logs/data/cache/models/food_hive.dart';
import 'package:calinout/features/nutrient_logs/data/cache/models/meal_hive.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_service.g.dart';

@Riverpod(keepAlive: true)
HiveService hiveService(Ref ref) {
  return HiveService.instance;
}

class HiveService {
  static HiveService? _instance;
  HiveService._();

  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  bool _isInitialized = false;

  /// Initialize Hive and register all adapters
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register all type adapters
    _registerAdapters();

    // Open boxes
    await _openBoxes();

    _isInitialized = true;
  }

  /// Register all Hive type adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(FoodTypeHiveAdapter().typeId)) {
      Hive.registerAdapter(FoodTypeHiveAdapter());
    }
    // Register other adapters here as you add more entities

    if (!Hive.isAdapterRegistered(FoodHiveAdapter().typeId)) {
      Hive.registerAdapter(FoodHiveAdapter());
    }

    if (!Hive.isAdapterRegistered(MealHiveAdapter().typeId)) {
      Hive.registerAdapter(MealHiveAdapter());
    }

    if (!Hive.isAdapterRegistered(DailyLogHiveAdapter().typeId)) {
      Hive.registerAdapter(DailyLogHiveAdapter());
    }
  }

  /// Open all required boxes
  Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<FoodTypeHive>(HiveBoxNames.foodTypeCache),
      Hive.openBox<FoodHive>(HiveBoxNames.foodCache),
      Hive.openBox<MealHive>(HiveBoxNames.mealCache),
      Hive.openBox<FoodHive>(HiveBoxNames.foodCache),
      Hive.openBox<DailyLogHive>(HiveBoxNames.dailyLogCache),
      Hive.openBox(HiveBoxNames.cacheMetadata),
      Hive.openBox(HiveBoxNames.appSettings),
    ]);
  }

  /// Get a box by name with type safety
  Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open. Call init() first.');
    }
    return Hive.box<T>(boxName);
  }

  /// Clear all cache boxes (useful for logout or data refresh)
  Future<void> clearAllCache() async {
    await Future.wait([
      Hive.box<FoodTypeHive>(HiveBoxNames.foodTypeCache).clear(),
      Hive.box<FoodHive>(HiveBoxNames.foodCache).clear(),
      Hive.box(HiveBoxNames.cacheMetadata).clear(),
      Hive.box<MealHive>(HiveBoxNames.mealCache).clear(),
    ]);
  }

  /// Clear specific cache box
  Future<void> clearCache(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Close all boxes (call on app dispose if needed)
  Future<void> closeAll() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Check if cache is stale (older than duration)
  bool isCacheStale(String key, Duration maxAge) {
    final metadataBox = Hive.box(HiveBoxNames.cacheMetadata);
    final lastFetch = metadataBox.get(key) as DateTime?;

    if (lastFetch == null) return true;

    return DateTime.now().difference(lastFetch) > maxAge;
  }

  /// Update cache timestamp
  Future<void> updateCacheTimestamp(String key) async {
    final metadataBox = Hive.box(HiveBoxNames.cacheMetadata);
    await metadataBox.put(key, DateTime.now());
  }
}
