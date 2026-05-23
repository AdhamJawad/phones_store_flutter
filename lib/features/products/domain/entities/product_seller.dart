class ProductSeller {
  const ProductSeller({
    required this.id,
    required this.name,
    this.username,
    this.location,
  });

  final int id;
  final String name;
  final String? username;
  final String? location;
}
