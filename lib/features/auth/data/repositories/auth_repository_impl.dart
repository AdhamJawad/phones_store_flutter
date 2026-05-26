import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../core/utils/unit.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl extends BaseRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required NetworkHandler networkHandler,
    required this.remoteDataSource,
    required this.localDataSource,
  }) : super(networkHandler);

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return guard(() async {
      final session = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await localDataSource.persist(session);
      return session.toEntity();
    });
  }

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  }) {
    return guard(() async {
      final session = await remoteDataSource.login(
        email: email,
        password: password,
        deviceName: deviceName,
      );
      await localDataSource.persist(session);
      return session.toEntity();
    });
  }

  @override
  Future<Result<Unit>> logout() {
    return guard(() async {
      await remoteDataSource.logout();
      await localDataSource.clear();
      return Unit.value;
    });
  }

  @override
  Future<Result<AuthSession?>> restoreSession() {
    return guard(() async {
      final persistedSession = await localDataSource.read();
      if (persistedSession == null) {
        return null;
      }

      final user = await remoteDataSource.fetchCurrentUser();
      await localDataSource.updateUser(user);

      return AuthSessionModel(
        token: persistedSession.token,
        tokenType: persistedSession.tokenType,
        user: user,
      ).toEntity();
    }).then((result) async {
      if (result case Error<AuthSession?>(
        :final failure,
      ) when failure is UnauthorizedFailure || failure is ForbiddenFailure) {
        await localDataSource.clear();
        return const Success<AuthSession?>(null);
      }

      return result;
    });
  }

  @override
  Future<Result<AuthSession>> refreshCurrentUser() async {
    final persistedSession = await localDataSource.read();
    if (persistedSession == null) {
      return const Error<AuthSession>(
        CacheFailure(message: 'No persisted session found.'),
      );
    }

    final result = await guard(() async {
      final user = await remoteDataSource.fetchCurrentUser();
      await localDataSource.updateUser(user);

      return AuthSessionModel(
        token: persistedSession.token,
        tokenType: persistedSession.tokenType,
        user: user,
      ).toEntity();
    });

    if (result case Error<AuthSession>(
      :final failure,
    ) when failure is UnauthorizedFailure || failure is ForbiddenFailure) {
      await localDataSource.clear();
    }

    return result;
  }
}
