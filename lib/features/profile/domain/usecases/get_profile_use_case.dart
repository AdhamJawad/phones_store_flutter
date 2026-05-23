import '../../../../core/errors/result.dart';
import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileUser>> call() {
    return _repository.getProfile();
  }
}
