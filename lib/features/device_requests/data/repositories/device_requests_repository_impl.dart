import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../core/utils/unit.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../../home/domain/entities/device_request.dart';
import '../../../home/domain/entities/device_request_page.dart';
import '../../domain/entities/create_device_request_input.dart';
import '../../domain/repositories/device_requests_repository.dart';
import '../datasources/device_requests_remote_data_source.dart';

class DeviceRequestsRepositoryImpl extends BaseRepositoryImpl
    implements DeviceRequestsRepository {
  DeviceRequestsRepositoryImpl({
    required NetworkHandler networkHandler,
    required DeviceRequestsRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final DeviceRequestsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DeviceRequest>> createDeviceRequest(
    CreateDeviceRequestInput input,
  ) {
    return guard(
      () => _remoteDataSource.createDeviceRequest(
        brand: input.brand,
        model: input.model,
        notes: input.notes,
      ),
    );
  }

  @override
  Future<Result<DeviceRequestPage>> getDeviceRequests({int page = 1}) {
    return guard(() => _remoteDataSource.getDeviceRequests(page: page));
  }

  @override
  Future<Result<Unit>> sendOffer(int deviceRequestId) {
    return guard(() async {
      await _remoteDataSource.sendOffer(deviceRequestId);
      return Unit.value;
    });
  }
}
