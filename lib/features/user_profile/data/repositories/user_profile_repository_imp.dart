import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/user_profile/data/sources/dtos/update_user_profile.dart';
import 'package:calinout/features/user_profile/data/sources/dtos/user_profile_mapper_extension.dart';
import 'package:calinout/features/user_profile/data/sources/i_user_profile_api.dart';
import 'package:calinout/features/user_profile/data/sources/user_profile_api.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';
import 'package:calinout/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_repository_imp.g.dart';

@riverpod
UserProfileRepository profileRepository(Ref ref) {
  return UserProfileRepositoryImp(ref.watch(userProfileApiProvider));
}

class UserProfileRepositoryImp implements UserProfileRepository {
  final IUserProfileApi _datasource;
  UserProfileRepositoryImp(this._datasource);

  @override
  Future<Result<UserProfile>> get() async {
    try {
      final response = await _datasource.get();
      final userProfileEntity = response.toEntity();
      return Result.success(userProfileEntity);
    } catch (e, s) {
      return Result.failure(e, s);
    }
  }

  @override
  Future<Result<UserProfile>> update(UserProfile profile) async {
    try {
      var updateRequest = UpdateUserProfile(
        firstName: profile.firstName,
        lastName: profile.lastName,
        heightInCm: profile.heightInCm,
        weightInKg: profile.weightInKg,
        gender: profile.gender == Gender.male ? 0 : 1,
        measurementSystem: profile.measurementSystem == MeasurementSystem.metric
            ? 'Metric'
            : 'Imperial',
        birthDate: profile.birthDate,
      );

      await _datasource.update(updateRequest);
      return Result.success(profile);
    } catch (e, s) {
      return Result.failure(e, s);
    }
  }
}
