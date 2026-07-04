import '../../../../core/errors/failure.dart';
import '../../../device_catalog/domain/entities/device.dart';
import '../../domain/entities/device_comparison.dart';

class DeviceCompareState {
  const DeviceCompareState({
    required this.availableDevices,
    required this.filteredDevices,
    required this.selectedDeviceIds,
    required this.searchQuery,
    required this.isLoadingOptions,
    required this.isSubmitting,
    this.comparison,
    this.failure,
    this.errorMessage,
  });

  const DeviceCompareState.initial()
    : availableDevices = const <Device>[],
      filteredDevices = const <Device>[],
      selectedDeviceIds = const <int>[],
      searchQuery = '',
      isLoadingOptions = true,
      isSubmitting = false,
      comparison = null,
      failure = null,
      errorMessage = null;

  final List<Device> availableDevices;
  final List<Device> filteredDevices;
  final List<int> selectedDeviceIds;
  final String searchQuery;
  final bool isLoadingOptions;
  final bool isSubmitting;
  final DeviceComparison? comparison;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canCompare => selectedDeviceIds.length == 2 && !isSubmitting;

  DeviceCompareState copyWith({
    List<Device>? availableDevices,
    List<Device>? filteredDevices,
    List<int>? selectedDeviceIds,
    String? searchQuery,
    bool? isLoadingOptions,
    bool? isSubmitting,
    DeviceComparison? comparison,
    Failure? failure,
    String? errorMessage,
    bool clearComparison = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return DeviceCompareState(
      availableDevices: availableDevices ?? this.availableDevices,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      comparison: clearComparison ? null : comparison ?? this.comparison,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
