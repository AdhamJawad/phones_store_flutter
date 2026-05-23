import '../../domain/entities/order_variant_summary.dart';

class OrderVariantSummaryModel extends OrderVariantSummary {
  const OrderVariantSummaryModel({
    required super.id,
    required super.colorName,
    super.colorCode,
    required super.stockQuantity,
  });

  factory OrderVariantSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderVariantSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      colorName: json['color_name'] as String? ?? '',
      colorCode: json['color_code'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
    );
  }
}
