import 'package:calinout/features/user_profile/data/sources/dtos/user_profile_response.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';

extension UserProfileMapper on UserProfileResponse {
  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      heightInCm: heightInCm,
      weightInKg: weightInKg,
      gender: gender == 0 ? Gender.male : Gender.female,
      measurementSystem: measurementSystem == 'Metric'
          ? MeasurementSystem.metric
          : MeasurementSystem.imperial,
      email: email,
      birthDate: birthDate,
    );
  }
}
