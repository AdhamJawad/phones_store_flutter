class CreateListingInput {
  const CreateListingInput({
    required this.brand,
    required this.model,
    required this.categoryId,
    required this.price,
    required this.condition,
    required this.location,
    required this.color,
    required this.imagePaths,
    this.description,
    this.conditionNotes,
    this.accessories,
    this.disassembledIs = false,
  });

  final String brand;
  final String model;
  final int categoryId;
  final double price;
  final String condition;
  final String? description;
  final String? conditionNotes;
  final String? accessories;
  final bool disassembledIs;
  final String location;
  final String color;
  final List<String> imagePaths;
}
