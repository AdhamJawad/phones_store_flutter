import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../../../home/data/models/device_request_model.dart';
import '../../../home/data/models/device_request_page_model.dart';

class DeviceRequestsRemoteDataSource {
  const DeviceRequestsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DeviceRequestPageModel> getDeviceRequests({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.deviceRequests,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final envelope = ApiResponseParser.parseEnvelope<List<DeviceRequestModel>>(
      response,
      (json) => _parseRequests(json),
    );

    return DeviceRequestPageModel.fromItemsMeta(
      items: envelope.data ?? const <DeviceRequestModel>[],
      meta: envelope.meta,
    );
  }

  Future<DeviceRequestModel> createDeviceRequest({
    required String brand,
    required String model,
    String? notes,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.deviceRequests,
      data: <String, dynamic>{
        'brand': brand,
        'model': model,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );
    if (payload.isEmpty) {
      throw const UnknownException('Malformed device request response.');
    }
    return DeviceRequestModel.fromJson(payload);
  }

  Future<void> sendOffer(int deviceRequestId) async {
    final response = await _dio.post<dynamic>(
      '${ApiPaths.deviceRequests}/$deviceRequestId/offer',
    );
    ApiResponseParser.ensureSuccessStatus(response);
  }

  List<DeviceRequestModel> _parseRequests(Object? raw) {
    if (raw is! List) {
      return const <DeviceRequestModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => DeviceRequestModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
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
