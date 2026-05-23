import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/profile_user_model.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProfileUserModel> getProfile() async {
    final response = await _dio.get<dynamic>(ApiPaths.me);
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed profile response.');
    }

    return ProfileUserModel.fromJson(payload);
  }

  Future<ProfileUserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.me,
      data: <String, dynamic>{
        'name': name,
        'email': email,
      },
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed profile response.');
    }

    return ProfileUserModel.fromJson(payload);
  }

  Future<void> deleteAccount() async {
    final response = await _dio.delete<dynamic>(ApiPaths.me);
    ApiResponseParser.ensureSuccessStatus(response);
  }

  Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const <String, dynamic>{};
  }
}
