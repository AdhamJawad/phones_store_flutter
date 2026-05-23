sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required String message}) : super(message);
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required String message}) : super(message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    this.errors = const <String, List<String>>{},
  }) : super(message);

  final Map<String, List<String>> errors;
}

final class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

final class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message);
}
