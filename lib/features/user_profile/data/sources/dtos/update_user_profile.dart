import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_user_profile.freezed.dart';
part 'update_user_profile.g.dart';

@freezed
abstract class UpdateUserProfile with _$UpdateUserProfile {
  factory UpdateUserProfile({
    required String? firstName,
    required String? lastName,
    required int? gender,
    required double? heightInCm,
    required double? weightInKg,
    required String? measurementSystem,
    required DateTime? birthDate,
  }) = _UpdateUserProfile;

  factory UpdateUserProfile.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserProfileFromJson(json);
}
