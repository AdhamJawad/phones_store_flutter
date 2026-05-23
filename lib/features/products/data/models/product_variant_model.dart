import '../../domain/entities/product_variant.dart';

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    required super.id,
    required super.colorName,
    super.colorCode,
    required super.stockQuantity,
    required super.priceModifier,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      colorName: json['color_name'] as String? ?? '',
      colorCode: json['color_code'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      priceModifier: (json['price_modifier'] as num?)?.toDouble() ?? 0,
    );
  }
}
