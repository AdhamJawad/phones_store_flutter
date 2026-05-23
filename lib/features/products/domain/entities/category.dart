class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.productsCount = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final int productsCount;
}
