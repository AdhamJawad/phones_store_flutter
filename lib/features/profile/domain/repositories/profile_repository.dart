import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../entities/profile_user.dart';
import '../entities/update_profile_input.dart';

abstract class ProfileRepository {
  Future<Result<ProfileUser>> getProfile();

  Future<Result<ProfileUser>> updateProfile(UpdateProfileInput input);

  Future<Result<Unit>> deleteAccount();
}
