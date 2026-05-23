import '../../../../core/errors/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RefreshCurrentUserUseCase {
  const RefreshCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call() {
    return _repository.refreshCurrentUser();
  }
}
