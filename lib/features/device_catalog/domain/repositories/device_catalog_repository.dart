import '../../../../core/errors/result.dart';
import '../entities/device.dart';
import '../entities/device_page.dart';

abstract class DeviceCatalogRepository {
  Future<Result<DevicePage>> getDevices({
    int page = 1,
    int perPage = 15,
    String? query,
    String? brand,
  });

  Future<Result<Device>> getDeviceDetails(int deviceId);
}
