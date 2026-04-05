import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/food_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/meal_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/state/nutrition_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nutrition_log_controller.g.dart';

//  Date range provider
// Defaults to the last 24 hours so the home screen can just watch this

@riverpod
class NutritionLogDateRange extends _$NutritionLogDateRange {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: now.add(Duration(minutes: 1)),
    );
  }

  void setRange(DateTimeRange range) => state = range;

  /// (midnight → now).
  void setToday() {
    final now = DateTime.now();
    state = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: now.add(Duration(minutes: 1)),
    );
  }

  void setLastDays(int days) {
    final now = DateTime.now();
    state = DateTimeRange(
      start: now.subtract(Duration(days: days)),
      end: now.add(Duration(minutes: 1)),
    );
  }
}

/////////////////

@Riverpod(keepAlive: true)
class NutritionLogInvalidator extends _$NutritionLogInvalidator {
  @override
  int build() => 0;

  void invalidate() => state++;
}

// ── Log controller ────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class NutritionLogController extends _$NutritionLogController {
  @override
  FutureOr<List<NutritionLogEntry>> build() async {
    // Re-fetch whenever the date range changes.
    final range = ref.watch(nutritionLogDateRangeProvider);

    return await _fetch(range);
  }

  Future<List<NutritionLogEntry>> _fetch(DateTimeRange range) async {
    final foodRepo = ref.read(foodRepositoryProvider);
    final mealRepo = ref.read(mealRepositoryProvider);

    // concurrently.
    final results = await Future.wait([
      foodRepo.getByDateRange(range.start, range.end, false, false),
      mealRepo.getByDateRange(range.start, range.end, false),
    ]);
    if (!ref.mounted) return [];

    final List<NutritionLogEntry> entries = [];

    switch (results[0] as Result<List<Food>>) {
      case Success(value: final foods):
        entries.addAll(foods.map(FoodEntry.new));
      case Failure(error: final e, stackTrace: final s):
        state = AsyncValue.error(e, s ?? StackTrace.current);
        return [];
    }

    switch (results[1] as Result<List<Meal>>) {
      case Success(value: final meals):
        entries.addAll(meals.map(MealEntry.new));
      case Failure(error: final e, stackTrace: final s):
        state = AsyncValue.error(e, s ?? StackTrace.current);
        return [];
    }

    // Most recent first.
    entries.sort((a, b) => b.sortDate.compareTo(a.sortDate));

    bool isDayfirstDay = true;

    DateTime currentDate = DateTime.now();

    for (int i = 0; i < entries.length; i++) {
      final entryDate = _handleEntryReturnDate(entries[i]);
      if (entryDate != null) {
        String title = _handleDateTextDisplay(entryDate);
        if (isDayfirstDay) {
          entries.insert(i, TitleEntry(title));
          currentDate = entryDate;
          isDayfirstDay = false;
        } else if (entryDate.day != currentDate.day) {
          currentDate = entryDate;
          entries.insert(i, TitleEntry(title));
        }
      }
    }
    return entries;
  }

  String _handleDateTextDisplay(DateTime date) {
    final fmt = DateFormat('d MMM');
    final fmtDayName = DateFormat('EEE d MMM');
    if (date.day == DateTime.now().day) {
      return 'Today';
    } else {
      if (date.add(Duration(days: 7)).compareTo(DateTime.now()) == 1) {
        return fmtDayName.format(date);
      }
      return fmt.format(date);
    }
  }

  DateTime? _handleEntryReturnDate(NutritionLogEntry entry) {
    DateTime date;
    switch (entry) {
      case FoodEntry(:final food):
        date = food.consumedAt ?? food.createdAt;
      case MealEntry(:final meal):
        date = meal.consumedAt ?? meal.createdAt;
      case TitleEntry():
        return null;
    }
    return date;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(nutritionLogDateRangeProvider)),
    );
  }
}
