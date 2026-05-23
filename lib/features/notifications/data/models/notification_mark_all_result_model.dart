import '../../domain/entities/notification_mark_all_result.dart';

class NotificationMarkAllResultModel extends NotificationMarkAllResult {
  const NotificationMarkAllResultModel({
    required super.updatedCount,
  });

  factory NotificationMarkAllResultModel.fromJson(Map<String, dynamic> json) {
    return NotificationMarkAllResultModel(
      updatedCount: (json['updated_count'] as num?)?.toInt() ?? 0,
    );
  }
}
