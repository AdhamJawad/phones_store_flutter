import '../../../../core/errors/result.dart';
import '../../../home/domain/entities/device_request_page.dart';
import '../repositories/device_requests_repository.dart';

class GetDeviceRequestsUseCase {
  const GetDeviceRequestsUseCase(this._repository);

  final DeviceRequestsRepository _repository;

  Future<Result<DeviceRequestPage>> call({
    int page = 1,
  }) {
    return _repository.getDeviceRequests(page: page);
  }
}
