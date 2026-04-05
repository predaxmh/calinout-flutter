import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive_ce.dart';

part 'daily_log_hive.g.dart';

@HiveType(typeId: 3)
class DailyLogHive extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int burnedCalories;

  @HiveField(4)
  final double? weightAtLog;

  @HiveField(5)
  final bool digestiveTrackCleared;

  @HiveField(6)
  final bool isCheatDay;

  @HiveField(7)
  final int totalCalories;

  @HiveField(8)
  final String dailyNotes;

  @HiveField(9)
  final int targetCalorieOnThisDay;

  @HiveField(10)
  final double totalFoodWeight;

  @HiveField(11)
  final double totalFat;

  @HiveField(12)
  final double totalCarbs;

  @HiveField(13)
  final double totalProtein;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime? updatedAt;

  DailyLogHive({
    required this.id,
    required this.userId,
    required this.date,
    required this.burnedCalories,
    this.weightAtLog,
    required this.digestiveTrackCleared,
    required this.isCheatDay,
    required this.totalCalories,
    this.dailyNotes = '',
    required this.targetCalorieOnThisDay,
    required this.totalFoodWeight,
    required this.totalFat,
    required this.totalCarbs,
    required this.totalProtein,
    required this.createdAt,
    this.updatedAt,
  });

  DailyLog toEntity() {
    return DailyLog(
      id: id,
      userId: userId,
      date: date,
      burnedCalories: burnedCalories,
      weightAtLog: weightAtLog,
      digestiveTrackCleared: digestiveTrackCleared,
      isCheatDay: isCheatDay,
      totalCalories: totalCalories,
      dailyNotes: dailyNotes,
      targetCalorieOnThisDay: targetCalorieOnThisDay,
      totalFoodWeight: totalFoodWeight,
      totalFat: totalFat,
      totalCarbs: totalCarbs,
      totalProtein: totalProtein,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a Hive Model from a Domain Entity.
  factory DailyLogHive.fromEntity(DailyLog entity) {
    return DailyLogHive(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      burnedCalories: entity.burnedCalories,
      weightAtLog: entity.weightAtLog,
      digestiveTrackCleared: entity.digestiveTrackCleared,
      isCheatDay: entity.isCheatDay,
      totalCalories: entity.totalCalories,
      dailyNotes: entity.dailyNotes,
      targetCalorieOnThisDay: entity.targetCalorieOnThisDay,
      totalFoodWeight: entity.totalFoodWeight,
      totalFat: entity.totalFat,
      totalCarbs: entity.totalCarbs,
      totalProtein: entity.totalProtein,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
