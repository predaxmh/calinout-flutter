import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';

abstract interface class UserProfileRepository {
  Future<Result<UserProfile>> get();
  Future<Result<UserProfile>> update(UserProfile profile);
}
