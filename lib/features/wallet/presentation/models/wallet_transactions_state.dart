import '../../../../core/errors/failure.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionsState {
  const WalletTransactionsState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    this.meta,
    this.failure,
    this.errorMessage,
  });

  const WalletTransactionsState.initial()
      : items = const <WalletTransaction>[],
        isLoading = true,
        isRefreshing = false,
        isLoadingMore = false,
        meta = null,
        failure = null,
        errorMessage = null;

  final List<WalletTransaction> items;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final PaginatedResponseMeta? meta;
  final Failure? failure;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canLoadMore => meta?.hasMorePages ?? false;

  WalletTransactionsState copyWith({
    List<WalletTransaction>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    PaginatedResponseMeta? meta,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return WalletTransactionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      meta: meta ?? this.meta,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
