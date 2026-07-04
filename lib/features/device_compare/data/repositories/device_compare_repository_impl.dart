import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/device_comparison.dart';
import '../../domain/repositories/device_compare_repository.dart';
import '../datasources/device_compare_remote_data_source.dart';

class DeviceCompareRepositoryImpl extends BaseRepositoryImpl
    implements DeviceCompareRepository {
  DeviceCompareRepositoryImpl({
    required NetworkHandler networkHandler,
    required DeviceCompareRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource,
       super(networkHandler);

  final DeviceCompareRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DeviceComparison>> compareDevices({
    required List<int> deviceIds,
  }) {
    return guard(() => _remoteDataSource.compareDevices(deviceIds: deviceIds));
  }
}
