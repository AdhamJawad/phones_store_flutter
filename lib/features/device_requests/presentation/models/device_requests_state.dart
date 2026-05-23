import '../../../../core/errors/failure.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../../home/domain/entities/device_request.dart';

class DeviceRequestsState {
  const DeviceRequestsState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.offeringIds,
    this.meta,
    this.failure,
    this.errorMessage,
  });

  const DeviceRequestsState.initial()
      : items = const <DeviceRequest>[],
        isLoading = true,
        isRefreshing = false,
        isLoadingMore = false,
        offeringIds = const <int>{},
        meta = null,
        failure = null,
        errorMessage = null;

  final List<DeviceRequest> items;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final Set<int> offeringIds;
  final PaginatedResponseMeta? meta;
  final Failure? failure;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canLoadMore => meta?.hasMorePages ?? false;

  DeviceRequestsState copyWith({
    List<DeviceRequest>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    Set<int>? offeringIds,
    PaginatedResponseMeta? meta,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return DeviceRequestsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      offeringIds: offeringIds ?? this.offeringIds,
      meta: meta ?? this.meta,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
