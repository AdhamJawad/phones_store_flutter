import 'package:dio/dio.dart';

class RequestGuardInterceptor extends Interceptor {
  final Map<String, DateTime> _inFlightMutations = <String, DateTime>{};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final key = _requestKey(options);
    if (_isMutating(options.method)) {
      final existing = _inFlightMutations[key];
      if (existing != null &&
          DateTime.now().difference(existing) < const Duration(seconds: 15)) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Duplicate request blocked.',
          ),
        );
        return;
      }

      _inFlightMutations[key] = DateTime.now();
    }

    options.extra['request_guard_key'] = key;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _clear(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _clear(err.requestOptions);
    handler.next(err);
  }

  void _clear(RequestOptions options) {
    final key = options.extra['request_guard_key'];
    if (key is String) {
      _inFlightMutations.remove(key);
    }
  }

  bool _isMutating(String method) {
    final upper = method.toUpperCase();
    return upper == 'POST' || upper == 'PATCH' || upper == 'PUT' || upper == 'DELETE';
  }

  String _requestKey(RequestOptions options) {
    final payload = switch (options.data) {
      FormData data =>
        'form:${data.fields.length}:${data.files.length}:${data.fields.map((field) => '${field.key}=${field.value}').join('&')}',
      Map<Object?, Object?> data => data.toString(),
      List<Object?> data => data.toString(),
      null => '',
      final value => value.toString(),
    };
    return '${options.method}|${options.path}|${options.queryParameters}|$payload';
  }
}
