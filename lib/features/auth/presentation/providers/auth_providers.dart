import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/unit.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/refresh_current_user_use_case.dart';
import '../../domain/usecases/restore_session_use_case.dart';
import '../models/auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(tokenStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final refreshCurrentUserUseCaseProvider = Provider<RefreshCurrentUserUseCase>((
  ref,
) {
  return RefreshCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final authRouterNotifierProvider = Provider<AuthRouterNotifier>((ref) {
  final notifier = AuthRouterNotifier(ref.read(authControllerProvider));
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    notifier.update(next);
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

class AuthController extends Notifier<AuthState> {
  bool _bootstrapped = false;
  Future<void>? _restoreFuture;
  Future<Result<AuthSession>>? _refreshFuture;

  RegisterUseCase get _registerUseCase => ref.read(registerUseCaseProvider);
  LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);
  LogoutUseCase get _logoutUseCase => ref.read(logoutUseCaseProvider);
  RestoreSessionUseCase get _restoreSessionUseCase =>
      ref.read(restoreSessionUseCaseProvider);
  RefreshCurrentUserUseCase get _refreshCurrentUserUseCase =>
      ref.read(refreshCurrentUserUseCaseProvider);

  @override
  AuthState build() {
    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(restoreSession);
    }

    return const AuthState.restoring();
  }

  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = AuthState(
      status: AuthStatus.unauthenticated,
      session: null,
      failure: null,
      errorMessage: null,
      isSubmitting: true,
    );

    final result = await _registerUseCase(
      name: name.trim(),
      email: email.trim(),
      phone: phone?.trim(),
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        state = AuthState.authenticated(data);
      case Error<AuthSession>(:final failure):
        state = AuthState.unauthenticated(
          failure: failure,
          errorMessage: _mapFailureToMessage(failure),
        );
    }

    return result;
  }

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    String deviceName = 'flutter_app',
  }) async {
    state = AuthState(
      status: AuthStatus.unauthenticated,
      session: null,
      failure: null,
      errorMessage: null,
      isSubmitting: true,
    );

    final result = await _loginUseCase(
      email: email.trim(),
      password: password,
      deviceName: deviceName,
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        state = AuthState.authenticated(data);
      case Error<AuthSession>(:final failure):
        state = AuthState.unauthenticated(
          failure: failure,
          errorMessage: _mapFailureToMessage(failure),
        );
    }

    return result;
  }

  Future<void> restoreSession() async {
    if (_restoreFuture != null) {
      return _restoreFuture;
    }

    state = const AuthState.restoring();
    _restoreFuture = _restoreSessionUseCase()
        .timeout(AppConstants.startupTimeout)
        .then((result) {
          switch (result) {
            case Success<AuthSession?>(:final data):
              if (data == null) {
                state = const AuthState.unauthenticated();
              } else {
                state = AuthState.authenticated(data);
              }
            case Error<AuthSession?>(:final failure):
              state = AuthState.unauthenticated(
                failure: failure,
                errorMessage: failure.isExpiredSession
                    ? null
                    : _mapFailureToMessage(failure),
              );
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          state = const AuthState.unauthenticated();
        })
        .whenComplete(() {
          _restoreFuture = null;
        });

    return _restoreFuture!;
  }

  Future<Result<AuthSession>> refreshCurrentUser() async {
    final inFlight = _refreshFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final previousSession = state.session;
    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      clearError: true,
    );

    final future = _refreshCurrentUserUseCase();
    _refreshFuture = future;
    final result = await future;

    switch (result) {
      case Success<AuthSession>(:final data):
        state = AuthState.authenticated(data);
      case Error<AuthSession>(:final failure):
        if (failure.isExpiredSession) {
          state = const AuthState.unauthenticated();
        } else if (previousSession != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            session: previousSession,
            failure: failure,
            errorMessage: _mapFailureToMessage(failure),
            isSubmitting: false,
          );
        } else {
          state = AuthState.unauthenticated(
            failure: failure,
            errorMessage: _mapFailureToMessage(failure),
          );
        }
    }

    _refreshFuture = null;
    return result;
  }

  Future<Result<Unit>> logout() async {
    final previousSession = state.session;
    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _logoutUseCase();

    switch (result) {
      case Success<Unit>():
        state = const AuthState.unauthenticated();
      case Error<Unit>(:final failure):
        if (failure.isExpiredSession) {
          state = const AuthState.unauthenticated();
        } else if (previousSession != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            session: previousSession,
            failure: failure,
            errorMessage: _mapFailureToMessage(failure),
            isSubmitting: false,
          );
        } else {
          state = AuthState.unauthenticated(
            failure: failure,
            errorMessage: _mapFailureToMessage(failure),
          );
        }
    }

    return result;
  }

  void clearError() {
    if (!state.hasError && state.failure == null) {
      return;
    }

    state = state.copyWith(clearError: true, clearFailure: true);
  }

  void replaceSessionUser(AuthUser user) {
    final session = state.session;
    if (session == null) {
      return;
    }

    state = AuthState.authenticated(
      AuthSession(
        token: session.token,
        tokenType: session.tokenType,
        user: user,
      ),
    );
  }

  void forceUnauthenticated() {
    state = const AuthState.unauthenticated();
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      NetworkFailure() =>
        'تعذر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مرة أخرى.',
      ServerFailure() => 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.',
      CacheFailure() => 'تعذر قراءة بيانات الجلسة المحفوظة.',
      ForbiddenFailure() => 'ليس لديك صلاحية لإتمام هذه العملية.',
      UnknownFailure() =>
        failure.message.isEmpty
            ? 'حدث خطأ غير متوقع. حاول مرة أخرى.'
            : failure.message,
    };
  }
}

class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterNotifier(this._state);

  AuthState _state;

  AuthState get state => _state;

  void update(AuthState value) {
    if (identical(_state, value)) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}
