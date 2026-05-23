import 'recharge_request.dart';
import 'wallet_summary.dart';
import 'wallet_transaction.dart';

class WalletDashboard {
  const WalletDashboard({
    required this.summary,
    required this.recentTransactions,
    required this.recentRechargeRequests,
  });

  final WalletSummary summary;
  final List<WalletTransaction> recentTransactions;
  final List<RechargeRequest> recentRechargeRequests;
}
