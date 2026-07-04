import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_page.dart';
import '../../domain/repositories/device_catalog_repository.dart';
import '../datasources/device_catalog_remote_data_source.dart';

class DeviceCatalogRepositoryImpl extends BaseRepositoryImpl
    implements DeviceCatalogRepository {
  DeviceCatalogRepositoryImpl({
    required NetworkHandler networkHandler,
    required DeviceCatalogRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource,
       super(networkHandler);

  final DeviceCatalogRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DevicePage>> getDevices({
    int page = 1,
    int perPage = 15,
    String? query,
    String? brand,
  }) {
    return guard(
      () => _remoteDataSource.getDevices(
        page: page,
        perPage: perPage,
        query: query,
        brand: brand,
      ),
    );
  }

  @override
  Future<Result<Device>> getDeviceDetails(int deviceId) {
    return guard(() => _remoteDataSource.getDeviceDetails(deviceId));
  }
}
