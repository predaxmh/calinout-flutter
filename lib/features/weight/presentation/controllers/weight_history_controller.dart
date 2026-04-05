import 'dart:async';

import 'package:calinout/core/utils/date_utils.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/home_manager/data/repositories/daily_log_repository_imp.dart';
import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_history_controller.g.dart';

enum WeightRange {
  week(7, '7D'),
  month(30, '30D'),
  quarter(90, '90D');

  final int days;
  final String label;
  const WeightRange(this.days, this.label);
}

@riverpod
class WeightRangeSelector extends _$WeightRangeSelector {
  @override
  WeightRange build() => WeightRange.month;

  void select(WeightRange range) => state = range;
}

// ── Weight entry — a daily log slimmed to just what the weight page needs ──

class WeightEntry {
  final DateTime date;
  final double weightKg;
  final String? notes;
  final DailyLog sourceLog; // kept so the edit sheet can copyWith and update

  const WeightEntry({
    required this.date,
    required this.weightKg,
    required this.notes,
    required this.sourceLog,
  });
}

// ── Controller ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class WeightHistoryController extends _$WeightHistoryController {
  @override
  FutureOr<List<WeightEntry>> build() async {
    final range = ref.watch(weightRangeSelectorProvider);
    return _fetch(range);
  }

  Future<List<WeightEntry>> _fetch(WeightRange range) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: range.days - 1));

    final repo = ref.read(dailyLogRepositoryProvider);
    final result = await repo.getByDateRange(start, today);

    if (!ref.mounted) return [];

    return switch (result) {
      Success(value: final logs) => toWeightEntries(logs),
      Failure(error: final e, stackTrace: final s) => () {
        state = AsyncValue.error(e, s ?? StackTrace.current);
        return <WeightEntry>[];
      }(),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final range = ref.read(weightRangeSelectorProvider);
    state = await AsyncValue.guard(() => _fetch(range));
  }

  /// Called after editing a weight entry from DailyLogController.
  /// Avoids a full network refetch for a single value change.
  void updateEntryLocal(DateTime date, double? newWeight, DailyLog updatedLog) {
    final current = state.value ?? [];
    if (newWeight == null || newWeight <= 0) {
      // Weight was cleared — remove entry
      state = AsyncData(
        current.where((e) => !isSameDay(e.date, date)).toList(),
      );
      return;
    }
    final exists = current.any((e) => isSameDay(e.date, date));
    if (exists) {
      state = AsyncData(
        current
            .map(
              (e) => isSameDay(e.date, date)
                  ? WeightEntry(
                      date: date,
                      weightKg: newWeight,
                      notes: updatedLog.dailyNotes,
                      sourceLog: updatedLog,
                    )
                  : e,
            )
            .toList(),
      );
    } else {
      // New entry for a day that had none — insert sorted
      final updated = [
        ...current,
        WeightEntry(
          date: date,
          weightKg: newWeight,
          notes: updatedLog.dailyNotes,
          sourceLog: updatedLog,
        ),
      ]..sort((a, b) => b.date.compareTo(a.date));
      state = AsyncData(updated);
    }
  }
}

// ── Derived stats ──────────────────────────────────────────────────────────

class WeightStats {
  final double current;
  final double highest;
  final double lowest;
  final double average;
  final double change; // positive = gained, negative = lost
  final int streak; // consecutive days logged

  const WeightStats({
    required this.current,
    required this.highest,
    required this.lowest,
    required this.average,
    required this.change,
    required this.streak,
  });
}

@riverpod
WeightStats? weightStats(Ref ref) {
  final entries = ref.watch(weightHistoryControllerProvider).value ?? [];
  if (entries.isEmpty) return null;

  final weights = entries.map((e) => e.weightKg).toList();

  // Streak — count consecutive days from today backwards
  final now = DateTime.now();
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final day = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: i));
    final has = entries.any(
      (e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day,
    );
    if (has) {
      streak++;
    } else {
      break;
    }
  }

  return WeightStats(
    current: weights.first,
    highest: weights.reduce((a, b) => a > b ? a : b),
    lowest: weights.reduce((a, b) => a < b ? a : b),
    average: weights.reduce((a, b) => a + b) / weights.length,
    // Change = current vs oldest in range
    change: weights.first - weights.last,
    streak: streak,
  );
}
