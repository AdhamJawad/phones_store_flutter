import 'category.dart';
import 'product_image.dart';
import 'product_seller.dart';
import 'product_variant.dart';

class Product {
  const Product({
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
    this.defects,
    this.conditionNotes,
    this.accessories,
    this.disassembledIs = false,
    this.reasonDisassembly,
    this.color,
    this.location,
    this.primaryImageUrl,
    this.createdAt,
    this.updatedAt,
    this.seller,
    this.category,
    this.images = const <ProductImage>[],
    this.variants = const <ProductVariant>[],
  });

  final int id;
  final String name;
  final String slug;
  final String brand;
  final String model;
  final String? description;
  final String? defects;
  final String? conditionNotes;
  final String? accessories;
  final bool disassembledIs;
  final String? reasonDisassembly;
  final double price;
  final String condition;
  final String status;
  final String source;
  final String? color;
  final String? location;
  final String? primaryImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProductSeller? seller;
  final Category? category;
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  bool get isInventory => source == 'inventory';
  bool get isMarketplace => source == 'user';
  String get displayTitle => name.trim().isNotEmpty ? name : '$brand $model';
}
