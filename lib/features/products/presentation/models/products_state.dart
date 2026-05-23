import '../../../../core/errors/failure.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/product.dart';

class ProductsState {
  const ProductsState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isRefreshing,
    required this.selectedSource,
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.meta,
    this.failure,
    this.errorMessage,
  });

  const ProductsState.initial({
    String? source,
    int? categoryId,
    String? categoryName,
  }) : items = const <Product>[],
       isLoading = true,
       isLoadingMore = false,
       isRefreshing = false,
       selectedSource = source,
       selectedCategoryId = categoryId,
       selectedCategoryName = categoryName,
       meta = null,
       failure = null,
       errorMessage = null;

  final List<Product> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? selectedSource;
  final int? selectedCategoryId;
  final String? selectedCategoryName;
  final PaginatedResponseMeta? meta;
  final Failure? failure;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canLoadMore => meta?.hasMorePages ?? false;

  ProductsState copyWith({
    List<Product>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? selectedSource,
    int? selectedCategoryId,
    String? selectedCategoryName,
    PaginatedResponseMeta? meta,
    Failure? failure,
    String? errorMessage,
    bool clearSource = false,
    bool clearCategory = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return ProductsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectedSource: clearSource ? null : selectedSource ?? this.selectedSource,
      selectedCategoryId: clearCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      selectedCategoryName: clearCategory
          ? null
          : selectedCategoryName ?? this.selectedCategoryName,
      meta: meta ?? this.meta,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
