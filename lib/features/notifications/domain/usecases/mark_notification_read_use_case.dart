import '../../../../core/errors/result.dart';
import '../entities/app_notification_item.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<AppNotificationItem>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
