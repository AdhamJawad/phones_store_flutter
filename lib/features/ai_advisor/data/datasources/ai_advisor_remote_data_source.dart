import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/ai_advisor_result_model.dart';

class AiAdvisorRemoteDataSource {
  const AiAdvisorRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AiAdvisorResultModel> askAdvisor({required String query}) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.aiAdvisor,
      data: <String, dynamic>{'query': query},
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed AI advisor response.');
    }

    return AiAdvisorResultModel.fromJson(payload);
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
