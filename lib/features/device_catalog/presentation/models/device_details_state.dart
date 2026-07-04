import '../../../../core/errors/failure.dart';
import '../../domain/entities/device.dart';

class DeviceDetailsState {
  const DeviceDetailsState({
    required this.isLoading,
    required this.isRefreshing,
    this.device,
    this.failure,
    this.errorMessage,
  });

  const DeviceDetailsState.initial()
    : isLoading = true,
      isRefreshing = false,
      device = null,
      failure = null,
      errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final Device? device;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  DeviceDetailsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Device? device,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return DeviceDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      device: device ?? this.device,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
