import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_session.dart';

enum AuthStatus {
  restoring,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.failure,
    this.errorMessage,
    this.isSubmitting = false,
  });

  const AuthState.restoring()
      : status = AuthStatus.restoring,
        session = null,
        failure = null,
        errorMessage = null,
        isSubmitting = false;

  const AuthState.authenticated(
    AuthSession this.session,
  )   : status = AuthStatus.authenticated,
        failure = null,
        errorMessage = null,
        isSubmitting = false;

  const AuthState.unauthenticated({
    this.failure,
    this.errorMessage,
    this.isSubmitting = false,
  })  : status = AuthStatus.unauthenticated,
        session = null;

  final AuthStatus status;
  final AuthSession? session;
  final Failure? failure;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isRestoring => status == AuthStatus.restoring;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    Failure? failure,
    String? errorMessage,
    bool? isSubmitting,
    bool clearFailure = false,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      failure: clearFailure ? null : (failure ?? this.failure),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
