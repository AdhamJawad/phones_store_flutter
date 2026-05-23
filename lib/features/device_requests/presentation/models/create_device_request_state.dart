import '../../../../core/errors/failure.dart';
import '../../../home/domain/entities/device_request.dart';

class CreateDeviceRequestState {
  const CreateDeviceRequestState({
    required this.isSubmitting,
    this.createdRequest,
    this.failure,
    this.errorMessage,
  });

  const CreateDeviceRequestState.initial()
      : isSubmitting = false,
        createdRequest = null,
        failure = null,
        errorMessage = null;

  final bool isSubmitting;
  final DeviceRequest? createdRequest;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  CreateDeviceRequestState copyWith({
    bool? isSubmitting,
    DeviceRequest? createdRequest,
    Failure? failure,
    String? errorMessage,
    bool clearCreatedRequest = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return CreateDeviceRequestState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdRequest: clearCreatedRequest
          ? null
          : createdRequest ?? this.createdRequest,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
