class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.type,
    required this.isRead,
    required this.hasAction,
    this.title,
    this.message,
    this.readAt,
    this.createdAt,
    this.meta = const <String, dynamic>{},
  });

  final String id;
  final String? title;
  final String? message;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final Map<String, dynamic> meta;
  final bool hasAction;

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    Map<String, dynamic>? meta,
    bool? hasAction,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      meta: meta ?? this.meta,
      hasAction: hasAction ?? this.hasAction,
    );
  }
}
