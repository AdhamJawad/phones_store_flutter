import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/notification_page.dart';
import 'app_notification_item_model.dart';

class NotificationPageModel extends NotificationPage {
  const NotificationPageModel({
    required super.items,
    super.meta,
  });

  factory NotificationPageModel.fromEnvelope({
    required List<AppNotificationItemModel> items,
    Map<String, dynamic>? meta,
  }) {
    return NotificationPageModel(
      items: items,
      meta: meta == null ? null : PaginatedResponseMeta.fromJson(meta),
    );
  }
}
