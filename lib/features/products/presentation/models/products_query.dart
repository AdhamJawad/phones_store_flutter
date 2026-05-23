class ProductsQuery {
  const ProductsQuery({
    this.source,
    this.categoryId,
    this.categoryName,
  });

  final String? source;
  final int? categoryId;
  final String? categoryName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductsQuery &&
            runtimeType == other.runtimeType &&
            source == other.source &&
            categoryId == other.categoryId &&
            categoryName == other.categoryName;
  }

  @override
  int get hashCode => Object.hash(source, categoryId, categoryName);
}
