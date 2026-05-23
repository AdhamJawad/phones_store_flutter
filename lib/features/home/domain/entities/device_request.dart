import 'device_request_user.dart';

class DeviceRequest {
  const DeviceRequest({
    required this.id,
    required this.brand,
    required this.model,
    required this.status,
    this.notes,
    this.createdAt,
    this.user,
  });

  final int id;
  final String brand;
  final String model;
  final String? notes;
  final String status;
  final DateTime? createdAt;
  final DeviceRequestUser? user;
}
