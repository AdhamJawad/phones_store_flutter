class CreateDeviceRequestInput {
  const CreateDeviceRequestInput({
    required this.brand,
    required this.model,
    this.notes,
  });

  final String brand;
  final String model;
  final String? notes;
}
