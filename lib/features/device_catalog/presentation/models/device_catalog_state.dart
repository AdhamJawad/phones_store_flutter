import '../../../../core/errors/failure.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/device.dart';

class DeviceCatalogState {
  const DeviceCatalogState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isRefreshing,
    required this.query,
    required this.selectedBrand,
    required this.availableBrands,
    this.meta,
    this.failure,
    this.errorMessage,
  });

  const DeviceCatalogState.initial()
    : items = const <Device>[],
      isLoading = true,
      isLoadingMore = false,
      isRefreshing = false,
      query = '',
      selectedBrand = null,
      availableBrands = const <String>[],
      meta = null,
      failure = null,
      errorMessage = null;

  final List<Device> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String query;
  final String? selectedBrand;
  final List<String> availableBrands;
  final PaginatedResponseMeta? meta;
  final Failure? failure;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canLoadMore => meta?.hasMorePages ?? false;

  DeviceCatalogState copyWith({
    List<Device>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? query,
    String? selectedBrand,
    List<String>? availableBrands,
    PaginatedResponseMeta? meta,
    Failure? failure,
    String? errorMessage,
    bool clearBrand = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return DeviceCatalogState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      query: query ?? this.query,
      selectedBrand: clearBrand ? null : selectedBrand ?? this.selectedBrand,
      availableBrands: availableBrands ?? this.availableBrands,
      meta: meta ?? this.meta,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
