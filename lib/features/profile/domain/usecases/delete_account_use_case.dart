import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<Unit>> call() {
    return _repository.deleteAccount();
  }
}
