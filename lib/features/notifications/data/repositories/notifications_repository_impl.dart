import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/app_notification_item.dart';
import '../../domain/entities/notification_mark_all_result.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl extends BaseRepositoryImpl
    implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NetworkHandler networkHandler,
    required NotificationsRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<NotificationPage>> getNotifications({int page = 1}) {
    return guard(() => _remoteDataSource.getNotifications(page: page));
  }

  @override
  Future<Result<NotificationMarkAllResult>> markAllAsRead() {
    return guard(_remoteDataSource.markAllAsRead);
  }

  @override
  Future<Result<AppNotificationItem>> markAsRead(String notificationId) {
    return guard(() => _remoteDataSource.markAsRead(notificationId));
  }
}
