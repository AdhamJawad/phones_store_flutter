sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred.']);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized request.']);
}

final class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Forbidden request.']);
}

final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.errors = const <String, List<String>>{},
  });

  final Map<String, List<String>> errors;
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred.']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred.']);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown error occurred.']);
}
