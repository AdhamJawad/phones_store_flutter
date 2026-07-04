import '../../../../core/errors/result.dart';
import '../entities/device.dart';
import '../repositories/device_catalog_repository.dart';

class GetDeviceDetailsUseCase {
  const GetDeviceDetailsUseCase(this._repository);

  final DeviceCatalogRepository _repository;

  Future<Result<Device>> call(int deviceId) {
    return _repository.getDeviceDetails(deviceId);
  }
}
