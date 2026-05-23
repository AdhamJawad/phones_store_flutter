import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/home_feed_model.dart';

class HomeRemoteDataSource {
  const HomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<HomeFeedModel> getHomeFeed() async {
    final response = await _dio.get<dynamic>(ApiPaths.home);
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed home response.');
    }

    return HomeFeedModel.fromJson(payload);
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }
}
