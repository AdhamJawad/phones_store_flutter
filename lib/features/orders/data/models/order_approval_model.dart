import '../../domain/entities/order_approval.dart';

class OrderApprovalModel extends OrderApproval {
  const OrderApprovalModel({required super.seller, required super.admin});

  factory OrderApprovalModel.fromJson(Map<String, dynamic> json) {
    return OrderApprovalModel(
      seller: _parseApprovalValue(json['seller']),
      admin: _parseApprovalValue(json['admin']),
    );
  }

  static bool? _parseApprovalValue(Object? value) {
    return switch (value) {
      null => null,
      bool value => value,
      num value => value != 0,
      String value when value == '1' || value.toLowerCase() == 'true' => true,
      String value when value == '0' || value.toLowerCase() == 'false' => false,
      _ => null,
    };
  }
}
