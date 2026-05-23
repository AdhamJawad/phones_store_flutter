import '../../../../core/errors/result.dart';
import '../entities/profile_user.dart';
import '../entities/update_profile_input.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileUser>> call(UpdateProfileInput input) {
    return _repository.updateProfile(input);
  }
}
