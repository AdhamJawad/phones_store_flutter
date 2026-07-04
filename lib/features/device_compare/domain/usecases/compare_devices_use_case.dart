import '../../../../core/errors/result.dart';
import '../entities/device_comparison.dart';
import '../repositories/device_compare_repository.dart';

class CompareDevicesUseCase {
  const CompareDevicesUseCase(this._repository);

  final DeviceCompareRepository _repository;

  Future<Result<DeviceComparison>> call({required List<int> deviceIds}) {
    return _repository.compareDevices(deviceIds: deviceIds);
  }
}
