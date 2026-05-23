import 'package:dio/dio.dart';

import '../config/app_constants.dart';
import '../config/env.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';
import 'interceptors/app_error_interceptor.dart';
import 'interceptors/auth_token_interceptor.dart';
import 'interceptors/request_guard_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class AppDioClient {
  AppDioClient(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status >= 200 && status < 500,
      ),
    );

    dio.interceptors.addAll([
      RequestGuardInterceptor(),
      AuthTokenInterceptor(_tokenStorage),
      AppErrorInterceptor(_tokenStorage),
      RetryInterceptor(dio),
      if (AppEnvironment.enableDioLogs)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
    ]);

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) {
          AppLogger.warning(
            'Network request failed: ${err.requestOptions.method} ${err.requestOptions.uri}',
            error: err,
            stackTrace: err.stackTrace,
          );
          handler.next(err);
        },
      ),
    );

    return dio;
  }
}
