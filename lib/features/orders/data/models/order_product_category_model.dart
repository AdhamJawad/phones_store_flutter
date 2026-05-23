import '../../domain/entities/order_product_category.dart';

class OrderProductCategoryModel extends OrderProductCategory {
  const OrderProductCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory OrderProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return OrderProductCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}
