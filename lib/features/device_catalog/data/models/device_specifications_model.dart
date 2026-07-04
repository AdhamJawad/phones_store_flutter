import '../../domain/entities/device_specifications.dart';

class DeviceSpecificationsModel extends DeviceSpecifications {
  const DeviceSpecificationsModel({
    super.battery,
    super.camera,
    super.storage,
    super.ram,
    super.processor,
    super.performance,
    super.display,
    super.operatingSystem,
  });

  factory DeviceSpecificationsModel.fromJson(Map<String, dynamic> json) {
    return DeviceSpecificationsModel(
      battery: json['battery'] as String?,
      camera: json['camera'] as String?,
      storage: json['storage'] as String?,
      ram: json['ram'] as String?,
      processor: json['processor'] as String?,
      performance: json['performance'] as String?,
      display: json['display'] as String?,
      operatingSystem: json['operating_system'] as String?,
    );
  }
}
