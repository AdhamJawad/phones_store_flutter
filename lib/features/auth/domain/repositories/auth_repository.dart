import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  });

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  });

  Future<Result<AuthSession?>> restoreSession();
  Future<Result<AuthSession>> refreshCurrentUser();
  Future<Result<Unit>> logout();
}
