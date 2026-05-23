import 'dart:async';

import 'package:dio/dio.dart';

import '../../app/app_error_reporter.dart';
import '../../logging/app_logger.dart';
import '../../storage/token_storage.dart';

class AppErrorInterceptor extends Interceptor {
  AppErrorInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _tokenStorage.clear();
    }

    if (err.type != DioExceptionType.cancel) {
      AppLogger.warning(
        'Dio exception intercepted: ${err.requestOptions.method} ${err.requestOptions.path}',
        error: err,
        stackTrace: err.stackTrace,
      );
      unawaited(
        AppErrorReporter.report(
          err,
          err.stackTrace,
          context: 'DioInterceptor',
        ),
      );
    }

    handler.next(err);
  }
}
