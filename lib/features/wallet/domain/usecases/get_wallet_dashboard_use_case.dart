import '../../../../core/errors/result.dart';
import '../entities/wallet_dashboard.dart';
import '../repositories/wallet_repository.dart';

class GetWalletDashboardUseCase {
  const GetWalletDashboardUseCase(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletDashboard>> call() => _repository.getWalletDashboard();
}
