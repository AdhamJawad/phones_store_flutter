import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/app_notification_item_model.dart';
import '../models/notification_mark_all_result_model.dart';
import '../models/notification_page_model.dart';

class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NotificationPageModel> getNotifications({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.notifications,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final envelope = ApiResponseParser.parseEnvelope<List<AppNotificationItemModel>>(
      response,
      (json) => _parseItems(json),
    );

    return NotificationPageModel.fromEnvelope(
      items: envelope.data ?? const <AppNotificationItemModel>[],
      meta: envelope.meta,
    );
  }

  Future<AppNotificationItemModel> markAsRead(String notificationId) async {
    final response = await _dio.post<dynamic>(
      '${ApiPaths.notifications}/$notificationId/read',
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed notification response.');
    }

    return AppNotificationItemModel.fromJson(payload);
  }

  Future<NotificationMarkAllResultModel> markAllAsRead() async {
    final response = await _dio.post<dynamic>(ApiPaths.notificationsReadAll);
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    return NotificationMarkAllResultModel.fromJson(payload);
  }

  List<AppNotificationItemModel> _parseItems(Object? raw) {
    if (raw is! List) {
      return const <AppNotificationItemModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => AppNotificationItemModel.fromJson(Map<String, dynamic>.from(item)))
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
