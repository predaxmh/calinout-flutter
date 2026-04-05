import 'package:flutter/material.dart';

@immutable
class DoodleCardListItemData {
  final DateTime time;
  final String name;
  final double weightValue;
  final double calorieValue;
  final double carbValue;
  final double fatValue;
  final double proteinValue;

  const DoodleCardListItemData({
    required this.time,
    required this.name,
    required this.weightValue,
    required this.calorieValue,
    required this.carbValue,
    required this.fatValue,
    required this.proteinValue,
  });

  factory DoodleCardListItemData.fromJson(Map<String, dynamic> json) {
    return DoodleCardListItemData(
      time: DateTime.parse(json['time'] as String),
      name: json['name'] as String,
      weightValue: (json['weight'] as num).toDouble(),
      calorieValue: (json['calories'] as num).toDouble(),
      carbValue: (json['carbs'] as num).toDouble(),
      fatValue: (json['fat'] as num).toDouble(),
      proteinValue: (json['protein'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'name': name,
      'weight': weightValue,
      'calories': calorieValue,
      'carbs': carbValue,
      'fat': fatValue,
      'protein': proteinValue,
    };
  }
}
