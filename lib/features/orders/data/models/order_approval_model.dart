import '../../domain/entities/order_approval.dart';

class OrderApprovalModel extends OrderApproval {
  const OrderApprovalModel({
    required super.seller,
    required super.admin,
  });

  factory OrderApprovalModel.fromJson(Map<String, dynamic> json) {
    return OrderApprovalModel(
      seller: json['seller'] as bool?,
      admin: json['admin'] as bool?,
    );
  }
}
