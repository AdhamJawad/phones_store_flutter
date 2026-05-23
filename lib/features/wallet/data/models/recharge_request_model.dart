import '../../domain/entities/recharge_method.dart';
import '../../domain/entities/recharge_request.dart';
import '../../domain/entities/recharge_request_status.dart';

class RechargeRequestModel extends RechargeRequest {
  const RechargeRequestModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.paymentMethod,
    required super.status,
    super.referenceNumber,
    super.notes,
    super.adminNotes,
    super.proofImageUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory RechargeRequestModel.fromJson(Map<String, dynamic> json) {
    return RechargeRequestModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? '',
      paymentMethod: RechargeMethod.fromApi(
        json['payment_method'] as String? ?? '',
      ),
      status: RechargeRequestStatus.fromApi(json['status'] as String? ?? ''),
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      proofImageUrl: json['proof_image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}
