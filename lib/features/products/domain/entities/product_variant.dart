class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.colorName,
    this.colorCode,
    required this.stockQuantity,
    required this.priceModifier,
  });

  final int id;
  final String colorName;
  final String? colorCode;
  final int stockQuantity;
  final double priceModifier;
}
