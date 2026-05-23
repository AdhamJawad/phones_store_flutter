import '../../domain/entities/order.dart';
import '../../domain/entities/order_payment_method.dart';
import '../../domain/entities/order_status.dart';
import 'order_approval_model.dart';
import 'order_party_model.dart';
import 'order_product_summary_model.dart';
import 'order_variant_summary_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderType,
    required super.status,
    required super.paymentMethod,
    required super.totalPrice,
    required super.shippingAddress,
    required super.approvals,
    super.createdAt,
    super.updatedAt,
    super.buyer,
    super.seller,
    super.product,
    super.variant,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderType: json['order_type'] as String? ?? '',
      status: OrderStatus.fromApi(json['status'] as String? ?? ''),
      paymentMethod: _paymentMethodFromApi(
        json['payment_method'] as String? ?? '',
      ),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      shippingAddress: json['shipping_address'] as String? ?? '',
      approvals: json['approvals'] is Map<String, dynamic>
          ? OrderApprovalModel.fromJson(json['approvals'] as Map<String, dynamic>)
          : json['approvals'] is Map
              ? OrderApprovalModel.fromJson(
                  Map<String, dynamic>.from(json['approvals'] as Map),
                )
              : const OrderApprovalModel(seller: null, admin: null),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      buyer: _parseParty(json['buyer']),
      seller: _parseParty(json['seller']),
      product: _parseProduct(json['product']),
      variant: _parseVariant(json['variant']),
    );
  }

  static OrderPaymentMethod _paymentMethodFromApi(String value) {
    return switch (value) {
      'wallet' => OrderPaymentMethod.wallet,
      'stripe' => OrderPaymentMethod.stripe,
      _ => OrderPaymentMethod.cod,
    };
  }

  static OrderPartyModel? _parseParty(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return OrderPartyModel.fromJson(raw);
    }

    if (raw is Map) {
      return OrderPartyModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return null;
  }

  static OrderProductSummaryModel? _parseProduct(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return OrderProductSummaryModel.fromJson(raw);
    }

    if (raw is Map) {
      return OrderProductSummaryModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return null;
  }

  static OrderVariantSummaryModel? _parseVariant(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return OrderVariantSummaryModel.fromJson(raw);
    }

    if (raw is Map) {
      return OrderVariantSummaryModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return null;
  }
}
