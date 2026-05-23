import 'order_payment_method.dart';

class CreateOrderInput {
  const CreateOrderInput({
    required this.productId,
    required this.shippingAddress,
    required this.paymentMethod,
    this.variantId,
  });

  final int productId;
  final int? variantId;
  final String shippingAddress;
  final OrderPaymentMethod paymentMethod;
}
