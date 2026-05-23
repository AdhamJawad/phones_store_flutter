import '../../domain/entities/product.dart';
import 'category_model.dart';
import 'product_image_model.dart';
import 'product_seller_model.dart';
import 'product_variant_model.dart';

class ProductModel extends Product {
  const ProductModel({
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
    super.defects,
    super.conditionNotes,
    super.accessories,
    super.disassembledIs,
    super.reasonDisassembly,
    super.color,
    super.location,
    super.primaryImageUrl,
    super.createdAt,
    super.updatedAt,
    super.seller,
    super.category,
    super.images,
    super.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      description: json['description'] as String?,
      defects: json['defects'] as String?,
      conditionNotes: json['condition_notes'] as String?,
      accessories: json['accessories'] as String?,
      disassembledIs: json['disassembled_is'] as bool? ?? false,
      reasonDisassembly: json['reason_disassembly'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      condition: json['condition'] as String? ?? '',
      status: json['status'] as String? ?? '',
      source: json['source'] as String? ?? '',
      color: json['color'] as String?,
      location: json['location'] as String?,
      primaryImageUrl: json['primary_image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      seller: json['seller'] is Map<String, dynamic>
          ? ProductSellerModel.fromJson(json['seller'] as Map<String, dynamic>)
          : json['seller'] is Map
              ? ProductSellerModel.fromJson(
                  Map<String, dynamic>.from(json['seller'] as Map),
                )
              : null,
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : json['category'] is Map
              ? CategoryModel.fromJson(
                  Map<String, dynamic>.from(json['category'] as Map),
                )
              : null,
      images: _parseList(
        json['images'],
        (value) => ProductImageModel.fromJson(value),
      ),
      variants: _parseList(
        json['variants'],
        (value) => ProductVariantModel.fromJson(value),
      ),
    );
  }

  static List<T> _parseList<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (raw is! List) {
      return <T>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
