import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/device_comparison_model.dart';

class DeviceCompareRemoteDataSource {
  const DeviceCompareRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DeviceComparisonModel> compareDevices({
    required List<int> deviceIds,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.compare,
      data: <String, dynamic>{'device_ids': deviceIds},
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed device comparison response.');
    }

    return DeviceComparisonModel.fromJson(payload);
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
