import 'package:calinout/features/user_profile/data/sources/dtos/update_user_profile.dart';
import 'package:calinout/features/user_profile/data/sources/dtos/user_profile_response.dart';

abstract class IUserProfileApi {
  Future<UserProfileResponse> get();
  Future<String> update(UpdateUserProfile updateDto);
}
