import '../../../../core/errors/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_payment_method.dart';

class CreateOrderState {
  const CreateOrderState({
    required this.paymentMethod,
    required this.isSubmitting,
    this.createdOrder,
    this.failure,
    this.errorMessage,
  });

  factory CreateOrderState.initial({
    required OrderPaymentMethod paymentMethod,
  }) {
    return CreateOrderState(
      paymentMethod: paymentMethod,
      isSubmitting: false,
      createdOrder: null,
      failure: null,
      errorMessage: null,
    );
  }

  final OrderPaymentMethod paymentMethod;
  final bool isSubmitting;
  final Order? createdOrder;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  CreateOrderState copyWith({
    OrderPaymentMethod? paymentMethod,
    bool? isSubmitting,
    Order? createdOrder,
    Failure? failure,
    String? errorMessage,
    bool clearCreatedOrder = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return CreateOrderState(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdOrder: clearCreatedOrder ? null : createdOrder ?? this.createdOrder,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
