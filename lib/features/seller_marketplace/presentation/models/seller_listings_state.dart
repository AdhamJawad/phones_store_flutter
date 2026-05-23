import '../../../../core/errors/failure.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../../products/domain/entities/product.dart';

class SellerListingsState {
  const SellerListingsState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.deletingIds,
    this.meta,
    this.failure,
    this.errorMessage,
  });

  const SellerListingsState.initial()
      : items = const <Product>[],
        isLoading = true,
        isRefreshing = false,
        isLoadingMore = false,
        deletingIds = const <int>{},
        meta = null,
        failure = null,
        errorMessage = null;

  final List<Product> items;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final Set<int> deletingIds;
  final PaginatedResponseMeta? meta;
  final Failure? failure;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canLoadMore => meta?.hasMorePages ?? false;

  SellerListingsState copyWith({
    List<Product>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    Set<int>? deletingIds,
    PaginatedResponseMeta? meta,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return SellerListingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      deletingIds: deletingIds ?? this.deletingIds,
      meta: meta ?? this.meta,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
