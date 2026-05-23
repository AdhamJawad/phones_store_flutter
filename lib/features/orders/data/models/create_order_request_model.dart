import '../../domain/entities/create_order_input.dart';

class CreateOrderRequestModel {
  const CreateOrderRequestModel(this.input);

  final CreateOrderInput input;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'product_id': input.productId,
      'shipping_address': input.shippingAddress,
      'payment_method': input.paymentMethod.apiValue,
      if (input.variantId != null) 'color': input.variantId,
    };
  }
}
