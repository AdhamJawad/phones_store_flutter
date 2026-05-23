import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  static const _publicPaths = {
    '/auth/login',
    '/home',
    '/search',
    '/products',
    '/categories',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isPublicPath = _publicPaths.any((publicPath) {
      return path == publicPath || path.startsWith('$publicPath/');
    });

    if (!isPublicPath) {
      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }
}
