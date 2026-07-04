import '../../../../core/errors/failure.dart';
import '../../domain/entities/device_comparison.dart';

class DeviceCompareResultState {
  const DeviceCompareResultState({
    required this.isLoading,
    required this.isRefreshing,
    this.comparison,
    this.failure,
    this.errorMessage,
  });

  const DeviceCompareResultState.initial()
    : isLoading = true,
      isRefreshing = false,
      comparison = null,
      failure = null,
      errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final DeviceComparison? comparison;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  DeviceCompareResultState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    DeviceComparison? comparison,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return DeviceCompareResultState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      comparison: comparison ?? this.comparison,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
