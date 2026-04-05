import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_response.freezed.dart';
part 'user_profile_response.g.dart';

@freezed
abstract class UserProfileResponse with _$UserProfileResponse {
  factory UserProfileResponse({
    required String userId,
    required String? firstName,
    required String? lastName,
    required int? gender,
    required double? heightInCm,
    required double? weightInKg,
    required String? measurementSystem,
    required String? email,
    required DateTime? birthDate,
  }) = _UserProfileResponse;

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);
}
