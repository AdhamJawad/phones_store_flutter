import '../../../../core/network/dto/paginated_response_meta.dart';
import 'device.dart';

class DevicePage {
  const DevicePage({required this.items, required this.meta});

  final List<Device> items;
  final PaginatedResponseMeta meta;
}
