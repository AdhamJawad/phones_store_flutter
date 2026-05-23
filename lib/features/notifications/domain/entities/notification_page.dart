import '../../../../core/network/dto/paginated_response_meta.dart';
import 'app_notification_item.dart';

class NotificationPage {
  const NotificationPage({
    required this.items,
    this.meta,
  });

  final List<AppNotificationItem> items;
  final PaginatedResponseMeta? meta;
}
