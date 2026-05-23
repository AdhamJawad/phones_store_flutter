import '../../../../core/errors/result.dart';
import '../entities/create_recharge_request_input.dart';
import '../entities/recharge_request.dart';
import '../entities/recharge_request_page.dart';
import '../entities/wallet_dashboard.dart';
import '../entities/wallet_summary.dart';
import '../entities/wallet_transaction_page.dart';

abstract class WalletRepository {
  Future<Result<WalletSummary>> getWalletSummary();

  Future<Result<WalletTransactionPage>> getTransactions({
    int page = 1,
  });

  Future<Result<RechargeRequestPage>> getRechargeRequests({
    int page = 1,
  });

  Future<Result<RechargeRequest>> createRechargeRequest(
    CreateRechargeRequestInput input,
  );

  Future<Result<WalletDashboard>> getWalletDashboard();
}
