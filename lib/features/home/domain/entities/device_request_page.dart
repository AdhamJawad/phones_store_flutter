import '../../../../core/network/dto/paginated_response_meta.dart';
import 'device_request.dart';

class DeviceRequestPage {
  const DeviceRequestPage({
    required this.items,
    required this.meta,
  });

  final List<DeviceRequest> items;
  final PaginatedResponseMeta meta;
}
