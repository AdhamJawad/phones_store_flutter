import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/device_request_page.dart';
import 'device_request_model.dart';

class DeviceRequestPageModel extends DeviceRequestPage {
  const DeviceRequestPageModel({
    required super.items,
    required super.meta,
  });

  factory DeviceRequestPageModel.fromItemsMeta({
    required List<DeviceRequestModel> items,
    Map<String, dynamic>? meta,
  }) {
    return DeviceRequestPageModel(
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

  factory DeviceRequestPageModel.fromEnvelope(Map<String, dynamic> envelope) {
    final rawData = envelope['data'];
    final rawMeta = envelope['meta'];

    return DeviceRequestPageModel(
      items: rawData is List
          ? rawData
              .whereType<Map>()
              .map((item) => DeviceRequestModel.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const <DeviceRequestModel>[],
      meta: rawMeta is Map<String, dynamic>
          ? PaginatedResponseMeta.fromJson(rawMeta)
          : rawMeta is Map
              ? PaginatedResponseMeta.fromJson(
                  Map<String, dynamic>.from(rawMeta),
                )
              : const PaginatedResponseMeta(
                  currentPage: 1,
                  lastPage: 1,
                  perPage: 0,
                  total: 0,
                  hasMorePages: false,
                ),
    );
  }
}
