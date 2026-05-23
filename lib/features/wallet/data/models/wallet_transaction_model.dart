import '../../domain/entities/wallet_transaction.dart';
import '../../domain/entities/wallet_transaction_type.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.balanceBefore,
    required super.balanceAfter,
    required super.reason,
    super.description,
    super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: WalletTransactionType.fromApi(json['type'] as String? ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceBefore: (json['balance_before'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
