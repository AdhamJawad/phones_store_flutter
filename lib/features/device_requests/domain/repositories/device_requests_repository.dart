import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../../../home/domain/entities/device_request.dart';
import '../../../home/domain/entities/device_request_page.dart';
import '../entities/create_device_request_input.dart';

abstract class DeviceRequestsRepository {
  Future<Result<DeviceRequestPage>> getDeviceRequests({
    int page = 1,
  });

  Future<Result<DeviceRequest>> createDeviceRequest(
    CreateDeviceRequestInput input,
  );

  Future<Result<Unit>> sendOffer(int deviceRequestId);
}
