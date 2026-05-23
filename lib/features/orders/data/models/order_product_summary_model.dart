import '../../domain/entities/order_product_summary.dart';
import 'order_product_category_model.dart';
import 'order_product_image_model.dart';

class OrderProductSummaryModel extends OrderProductSummary {
  const OrderProductSummaryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.brand,
    required super.model,
    required super.price,
    required super.condition,
    required super.status,
    required super.source,
    super.description,
    super.color,
    super.location,
    super.primaryImageUrl,
    super.category,
    super.images,
  });

  factory OrderProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderProductSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      condition: json['condition'] as String? ?? '',
      status: json['status'] as String? ?? '',
      source: json['source'] as String? ?? '',
      color: json['color'] as String?,
      location: json['location'] as String?,
      primaryImageUrl: json['primary_image_url'] as String?,
      category: json['category'] is Map<String, dynamic>
          ? OrderProductCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : json['category'] is Map
              ? OrderProductCategoryModel.fromJson(
                  Map<String, dynamic>.from(json['category'] as Map),
                )
              : null,
      images: _parseImages(json['images']),
    );
  }

  static List<OrderProductImageModel> _parseImages(Object? raw) {
    if (raw is! List) {
      return const <OrderProductImageModel>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) => OrderProductImageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }
}
