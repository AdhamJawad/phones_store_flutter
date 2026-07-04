import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/device_model.dart';
import '../models/device_page_model.dart';

class DeviceCatalogRemoteDataSource {
  const DeviceCatalogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DevicePageModel> getDevices({
    int page = 1,
    int perPage = 15,
    String? query,
    String? brand,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.devices,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      },
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final envelope = ApiResponseParser.parseEnvelope<List<DeviceModel>>(
      response,
      (json) => _parseDevices(json),
    );

    return DevicePageModel.fromEnvelope(
      items: envelope.data ?? const <DeviceModel>[],
      meta: envelope.meta,
    );
  }

  Future<DeviceModel> getDeviceDetails(int deviceId) async {
    final response = await _dio.get<dynamic>('${ApiPaths.devices}/$deviceId');
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed device details response.');
    }

    return DeviceModel.fromJson(payload);
  }

  List<DeviceModel> _parseDevices(Object? raw) {
    if (raw is! List) {
      return const <DeviceModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => DeviceModel.fromJson(Map<String, dynamic>.from(item)))
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
