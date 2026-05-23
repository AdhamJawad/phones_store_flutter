import '../../domain/entities/device_request.dart';
import 'device_request_user_model.dart';

class DeviceRequestModel extends DeviceRequest {
  const DeviceRequestModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.status,
    super.notes,
    super.createdAt,
    super.user,
  });

  factory DeviceRequestModel.fromJson(Map<String, dynamic> json) {
    return DeviceRequestModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      user: json['user'] is Map<String, dynamic>
          ? DeviceRequestUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : json['user'] is Map
              ? DeviceRequestUserModel.fromJson(
                  Map<String, dynamic>.from(json['user'] as Map),
                )
              : null,
    );
  }
}
