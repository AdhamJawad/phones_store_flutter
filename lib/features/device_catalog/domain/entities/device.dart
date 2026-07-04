import 'device_specifications.dart';

class Device {
  const Device({
    required this.id,
    required this.brand,
    required this.modelName,
    required this.slug,
    required this.name,
    required this.marketplaceProductsCount,
    required this.specifications,
    this.imageUrl,
    this.releaseYear,
  });

  final int id;
  final String brand;
  final String modelName;
  final String slug;
  final String name;
  final String? imageUrl;
  final int? releaseYear;
  final int marketplaceProductsCount;
  final DeviceSpecifications specifications;
}
