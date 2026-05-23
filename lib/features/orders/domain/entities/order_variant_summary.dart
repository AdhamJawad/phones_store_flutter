class OrderVariantSummary {
  const OrderVariantSummary({
    required this.id,
    required this.colorName,
    this.colorCode,
    required this.stockQuantity,
  });

  final int id;
  final String colorName;
  final String? colorCode;
  final int stockQuantity;
}
