import '../../domain/entities/app_notification_item.dart';

class AppNotificationItemModel extends AppNotificationItem {
  const AppNotificationItemModel({
    required super.id,
    required super.type,
    required super.isRead,
    required super.hasAction,
    super.title,
    super.message,
    super.readAt,
    super.createdAt,
    super.meta,
  });

  factory AppNotificationItemModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      readAt: DateTime.tryParse(json['read_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : json['meta'] is Map
              ? Map<String, dynamic>.from(json['meta'] as Map)
              : const <String, dynamic>{},
      hasAction: json['has_action'] as bool? ?? false,
    );
  }
}
