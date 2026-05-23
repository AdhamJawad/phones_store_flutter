import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/auth_user_model.dart';
import '../models/current_user_response_model.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final request = LoginRequestModel(
      email: email,
      password: password,
      deviceName: deviceName,
    );

    final response = await _dio.post<dynamic>(
      ApiPaths.authLogin,
      data: request.toJson(),
    );

    ApiResponseParser.ensureSuccessStatus(response);

    try {
      final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );

      return LoginResponseModel.fromJson(payload).toSessionModel();
    } catch (_) {
      throw const UnknownException('Malformed login response.');
    }
  }

  Future<AuthUserModel> fetchCurrentUser() async {
    final response = await _dio.get<dynamic>(ApiPaths.authMe);
    ApiResponseParser.ensureSuccessStatus(response);

    try {
      final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );

      return CurrentUserResponseModel.fromJson(payload).user;
    } catch (_) {
      throw const UnknownException('Malformed current user response.');
    }
  }

  Future<void> logout() async {
    final response = await _dio.post<dynamic>(ApiPaths.authLogout);
    ApiResponseParser.ensureSuccessStatus(response);
  }
}
