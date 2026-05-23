import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../repositories/device_requests_repository.dart';

class SendDeviceOfferUseCase {
  const SendDeviceOfferUseCase(this._repository);

  final DeviceRequestsRepository _repository;

  Future<Result<Unit>> call(int deviceRequestId) {
    return _repository.sendOffer(deviceRequestId);
  }
}
