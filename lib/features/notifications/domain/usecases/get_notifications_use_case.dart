import '../../../../core/errors/result.dart';
import '../entities/notification_page.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<NotificationPage>> call({
    int page = 1,
  }) {
    return _repository.getNotifications(page: page);
  }
}
