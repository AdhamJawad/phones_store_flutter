import 'wallet_transaction_type.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.reason,
    this.description,
    this.createdAt,
  });

  final int id;
  final WalletTransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String reason;
  final String? description;
  final DateTime? createdAt;
}
