import 'order_product_category.dart';
import 'order_product_image.dart';

class OrderProductSummary {
  const OrderProductSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.brand,
    required this.model,
    required this.price,
    required this.condition,
    required this.status,
    required this.source,
    this.description,
    this.color,
    this.location,
    this.primaryImageUrl,
    this.category,
    this.images = const <OrderProductImage>[],
  });

  final int id;
  final String name;
  final String slug;
  final String brand;
  final String model;
  final String? description;
  final double price;
  final String condition;
  final String status;
  final String source;
  final String? color;
  final String? location;
  final String? primaryImageUrl;
  final OrderProductCategory? category;
  final List<OrderProductImage> images;

  bool get isInventory => source == 'inventory';
  bool get isMarketplace => source == 'user';
  String get displayTitle => name.trim().isNotEmpty ? name : '$brand $model';
}
