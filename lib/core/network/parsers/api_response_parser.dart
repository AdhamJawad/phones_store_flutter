import 'package:dio/dio.dart';

import '../../errors/app_exception.dart';
import '../models/api_error_response.dart';
import '../models/api_response.dart';

final class ApiResponseParser {
  const ApiResponseParser._();

  static ApiResponse<T> parseEnvelope<T>(
    Response<dynamic> response,
    T Function(Object? json) fromJsonT,
  ) {
    final payload = _asMap(response.data);
    return ApiResponse<T>.fromJson(payload, fromJsonT);
  }

  static T parseData<T>(
    Response<dynamic> response,
    T Function(Object? json) fromJsonT,
  ) {
    final envelope = parseEnvelope(response, fromJsonT);
    return envelope.data as T;
  }

  static void ensureSuccessStatus(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 500;
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    throw _parseApiException(response);
  }

  static AppException parseDioError(DioException error) {
    final response = error.response;
    if (response == null) {
      return const NetworkException();
    }

    return _parseApiException(response);
  }

  static AppException _parseApiException(Response<dynamic> response) {
    final payload = _asMap(response.data);
    final statusCode = response.statusCode ?? 500;

    try {
      final error = ApiErrorResponse.fromJson(payload);

      return switch (statusCode) {
        401 => UnauthorizedException(error.message),
        403 => ForbiddenException(error.message),
        422 => ValidationException(error.message, errors: error.errors),
        >= 500 => ServerException(error.message),
        _ => UnknownException(error.message),
      };
    } catch (_) {
      return switch (statusCode) {
        401 => const UnauthorizedException(),
        403 => const ForbiddenException(),
        422 => const ValidationException('Validation error.'),
        >= 500 => const ServerException(),
        _ => const UnknownException(),
      };
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return const <String, dynamic>{};
  }
}
