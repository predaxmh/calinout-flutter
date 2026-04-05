// user_profile.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum MeasurementSystem {
  @JsonValue('Metric')
  metric,
  @JsonValue('Imperial')
  imperial,
}

enum Gender { male, female }

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    Gender? gender,
    double? heightInCm,
    double? weightInKg,
    String? email,
    DateTime? birthDate,
    MeasurementSystem? measurementSystem,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
