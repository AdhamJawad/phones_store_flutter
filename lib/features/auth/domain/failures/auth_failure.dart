import '../../../../core/errors/failure.dart';

extension AuthFailureX on Failure {
  bool get isInvalidCredentials =>
      this is UnauthorizedFailure || this is ValidationFailure;

  bool get isExpiredSession => this is UnauthorizedFailure;
}
