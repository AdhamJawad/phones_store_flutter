import '../../domain/entities/order_product_image.dart';

class OrderProductImageModel extends OrderProductImage {
  const OrderProductImageModel({
    required super.id,
    required super.url,
    required super.isPrimary,
  });

  factory OrderProductImageModel.fromJson(Map<String, dynamic> json) {
    return OrderProductImageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}
