import '../../domain/entities/device.dart';
import 'device_specifications_model.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.brand,
    required super.modelName,
    required super.slug,
    required super.name,
    required super.marketplaceProductsCount,
    required super.specifications,
    super.imageUrl,
    super.releaseYear,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String? ?? '',
      modelName: json['model_name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      releaseYear: (json['release_year'] as num?)?.toInt(),
      marketplaceProductsCount:
          (json['marketplace_products_count'] as num?)?.toInt() ?? 0,
      specifications: json['specifications'] is Map<String, dynamic>
          ? DeviceSpecificationsModel.fromJson(
              json['specifications'] as Map<String, dynamic>,
            )
          : json['specifications'] is Map
          ? DeviceSpecificationsModel.fromJson(
              Map<String, dynamic>.from(json['specifications'] as Map),
            )
          : const DeviceSpecificationsModel(),
    );
  }
}
