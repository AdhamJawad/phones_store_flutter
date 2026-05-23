import '../../../../core/errors/result.dart';
import '../entities/notification_mark_all_result.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<NotificationMarkAllResult>> call() {
    return _repository.markAllAsRead();
  }
}
