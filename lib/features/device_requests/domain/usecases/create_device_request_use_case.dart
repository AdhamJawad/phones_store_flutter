import '../../../../core/errors/result.dart';
import '../../../home/domain/entities/device_request.dart';
import '../entities/create_device_request_input.dart';
import '../repositories/device_requests_repository.dart';

class CreateDeviceRequestUseCase {
  const CreateDeviceRequestUseCase(this._repository);

  final DeviceRequestsRepository _repository;

  Future<Result<DeviceRequest>> call(CreateDeviceRequestInput input) {
    return _repository.createDeviceRequest(input);
  }
}
