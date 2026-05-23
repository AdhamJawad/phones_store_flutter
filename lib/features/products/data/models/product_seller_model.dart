import '../../domain/entities/product_seller.dart';

class ProductSellerModel extends ProductSeller {
  const ProductSellerModel({
    required super.id,
    required super.name,
    super.username,
    super.location,
  });

  factory ProductSellerModel.fromJson(Map<String, dynamic> json) {
    return ProductSellerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String?,
      location: json['location'] as String?,
    );
  }
}
