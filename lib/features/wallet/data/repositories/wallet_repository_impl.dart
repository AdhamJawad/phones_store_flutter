import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/create_recharge_request_input.dart';
import '../../domain/entities/recharge_request.dart';
import '../../domain/entities/recharge_request_page.dart';
import '../../domain/entities/wallet_dashboard.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/entities/wallet_transaction_page.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl extends BaseRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl({
    required NetworkHandler networkHandler,
    required WalletRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final WalletRemoteDataSource _remoteDataSource;

  @override
  Future<Result<RechargeRequest>> createRechargeRequest(
    CreateRechargeRequestInput input,
  ) {
    return guard(
      () => _remoteDataSource.createRechargeRequest(
        amount: input.amount,
        method: input.method,
        proofFilePath: input.proofFilePath,
      ),
    );
  }

  @override
  Future<Result<RechargeRequestPage>> getRechargeRequests({int page = 1}) {
    return guard(() => _remoteDataSource.getRechargeRequests(page: page));
  }

  @override
  Future<Result<WalletDashboard>> getWalletDashboard() {
    return guard(() async {
      final summary = await _remoteDataSource.getWalletSummary();
      final transactions = await _remoteDataSource.getTransactions();
      final rechargeRequests = await _remoteDataSource.getRechargeRequests();

      return WalletDashboard(
        summary: summary,
        recentTransactions: transactions.items.take(5).toList(growable: false),
        recentRechargeRequests:
            rechargeRequests.items.take(5).toList(growable: false),
      );
    });
  }

  @override
  Future<Result<WalletSummary>> getWalletSummary() {
    return guard(() => _remoteDataSource.getWalletSummary());
  }

  @override
  Future<Result<WalletTransactionPage>> getTransactions({int page = 1}) {
    return guard(() => _remoteDataSource.getTransactions(page: page));
  }
}
