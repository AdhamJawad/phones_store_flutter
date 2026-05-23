import 'recharge_method.dart';
import 'recharge_request_status.dart';

class RechargeRequest {
  const RechargeRequest({
    required this.id,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.status,
    this.referenceNumber,
    this.notes,
    this.adminNotes,
    this.proofImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final double amount;
  final String type;
  final RechargeMethod paymentMethod;
  final RechargeRequestStatus status;
  final String? referenceNumber;
  final String? notes;
  final String? adminNotes;
  final String? proofImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
