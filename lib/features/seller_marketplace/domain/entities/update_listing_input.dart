class UpdateListingInput {
  const UpdateListingInput({
    required this.brand,
    required this.model,
    required this.categoryId,
    required this.price,
    required this.condition,
    required this.color,
    required this.newImagePaths,
    required this.deleteImageIds,
    this.description,
    this.defects,
    this.accessories,
    this.disassembledIs = false,
    this.status,
  });

  final String brand;
  final String model;
  final int categoryId;
  final double price;
  final String condition;
  final String color;
  final String? status;
  final String? description;
  final String? defects;
  final String? accessories;
  final bool disassembledIs;
  final List<String> newImagePaths;
  final List<int> deleteImageIds;
}
