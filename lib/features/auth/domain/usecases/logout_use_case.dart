import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call() {
    return _repository.logout();
  }
}
