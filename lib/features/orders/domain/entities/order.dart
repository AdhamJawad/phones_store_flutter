import 'order_approval.dart';
import 'order_party.dart';
import 'order_payment_method.dart';
import 'order_product_summary.dart';
import 'order_status.dart';
import 'order_variant_summary.dart';

class Order {
  const Order({
    required this.id,
    required this.orderType,
    required this.status,
    required this.paymentMethod,
    required this.totalPrice,
    required this.shippingAddress,
    required this.approvals,
    this.createdAt,
    this.updatedAt,
    this.buyer,
    this.seller,
    this.product,
    this.variant,
  });

  final int id;
  final String orderType;
  final OrderStatus status;
  final OrderPaymentMethod paymentMethod;
  final double totalPrice;
  final String shippingAddress;
  final OrderApproval approvals;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final OrderParty? buyer;
  final OrderParty? seller;
  final OrderProductSummary? product;
  final OrderVariantSummary? variant;

  bool get isInventory => orderType == 'inventory';
  bool get isMarketplace => orderType == 'user';
}
