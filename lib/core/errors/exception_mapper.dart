import 'app_exception.dart';
import 'failure.dart';

final class ExceptionMapper {
  const ExceptionMapper._();

  static Failure map(Object error) {
    return switch (error) {
      NetworkException(:final message) => NetworkFailure(message: message),
      UnauthorizedException(:final message) =>
        UnauthorizedFailure(message: message),
      ForbiddenException(:final message) => ForbiddenFailure(message: message),
      ValidationException(:final message, :final errors) =>
        ValidationFailure(message: message, errors: errors),
      CacheException(:final message) => CacheFailure(message: message),
      ServerException(:final message) => ServerFailure(message: message),
      UnknownException(:final message) => UnknownFailure(message: message),
      _ => const UnknownFailure(message: 'Unexpected error occurred.'),
    };
  }
}
