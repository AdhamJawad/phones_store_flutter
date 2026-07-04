import '../../../../core/errors/result.dart';
import '../entities/device_comparison.dart';

abstract class DeviceCompareRepository {
  Future<Result<DeviceComparison>> compareDevices({
    required List<int> deviceIds,
  });
}
