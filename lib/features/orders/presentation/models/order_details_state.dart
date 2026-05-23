import '../../../../core/errors/failure.dart';
import '../../domain/entities/order.dart';

class OrderDetailsState {
  const OrderDetailsState({
    required this.isLoading,
    required this.isRefreshing,
    this.order,
    this.failure,
    this.errorMessage,
  });

  const OrderDetailsState.initial()
      : isLoading = true,
        isRefreshing = false,
        order = null,
        failure = null,
        errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final Order? order;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get hasData => order != null;

  OrderDetailsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Order? order,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return OrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      order: order ?? this.order,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
