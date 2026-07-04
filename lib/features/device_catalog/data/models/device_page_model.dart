import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/device_page.dart';
import 'device_model.dart';

class DevicePageModel extends DevicePage {
  const DevicePageModel({required super.items, required super.meta});

  factory DevicePageModel.fromEnvelope({
    required List<DeviceModel> items,
    Map<String, dynamic>? meta,
  }) {
    return DevicePageModel(
      items: items,
      meta: meta == null
          ? const PaginatedResponseMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
              hasMorePages: false,
            )
          : PaginatedResponseMeta.fromJson(meta),
    );
  }
}
