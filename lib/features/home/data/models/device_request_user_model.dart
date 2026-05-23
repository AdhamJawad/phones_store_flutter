import '../../domain/entities/device_request_user.dart';

class DeviceRequestUserModel extends DeviceRequestUser {
  const DeviceRequestUserModel({
    required super.id,
    required super.name,
    super.username,
  });

  factory DeviceRequestUserModel.fromJson(Map<String, dynamic> json) {
    return DeviceRequestUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String?,
    );
  }
}
