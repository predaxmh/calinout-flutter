class HiveBoxNames {
  HiveBoxNames._();

  // Cache boxes
  static const String foodTypeCache = 'food_type_cache';
  static const String foodCache = 'food_cache';
  static const String mealCache = 'meal_cache';
  static const String userCache = 'user_cache';
  static const String dailyLogCache = 'daily_log_cache';

  // Metadata boxes (for cache timestamps, etc.)
  static const String cacheMetadata = 'cache_metadata';

  // Settings
  static const String appSettings = 'app_settings';
}

/// Keys for cache metadata
class CacheMetadataKeys {
  CacheMetadataKeys._();

  static const String foodTypeLastFetch = 'food_type_last_fetch';
  static const String foodTypeSearchPrefix = 'food_type_search_';
  static const String foodLastFetch = 'food_last_fetch';
  static const String mealLastFetch = 'meal_last_fetch';
  static const String dailyLogLastFetch = 'daily_log_last_fetch';
}
