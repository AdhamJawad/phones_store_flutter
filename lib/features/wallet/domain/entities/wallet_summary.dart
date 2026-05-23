class WalletSummary {
  const WalletSummary({
    required this.userId,
    required this.balance,
    required this.transactionsCount,
    required this.rechargeRequestsCount,
    required this.pendingRechargeRequestsCount,
  });

  final int userId;
  final double balance;
  final int transactionsCount;
  final int rechargeRequestsCount;
  final int pendingRechargeRequestsCount;
}
