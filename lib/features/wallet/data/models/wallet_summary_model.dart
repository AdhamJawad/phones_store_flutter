import '../../domain/entities/wallet_summary.dart';

class WalletSummaryModel extends WalletSummary {
  const WalletSummaryModel({
    required super.userId,
    required super.balance,
    required super.transactionsCount,
    required super.rechargeRequestsCount,
    required super.pendingRechargeRequestsCount,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transactionsCount: (json['transactions_count'] as num?)?.toInt() ?? 0,
      rechargeRequestsCount:
          (json['recharge_requests_count'] as num?)?.toInt() ?? 0,
      pendingRechargeRequestsCount:
          (json['pending_recharge_requests_count'] as num?)?.toInt() ?? 0,
    );
  }
}
