import '../../../../core/errors/result.dart';
import '../entities/app_notification_item.dart';
import '../entities/notification_mark_all_result.dart';
import '../entities/notification_page.dart';

abstract class NotificationsRepository {
  Future<Result<NotificationPage>> getNotifications({
    int page = 1,
  });

  Future<Result<AppNotificationItem>> markAsRead(String notificationId);

  Future<Result<NotificationMarkAllResult>> markAllAsRead();
}
