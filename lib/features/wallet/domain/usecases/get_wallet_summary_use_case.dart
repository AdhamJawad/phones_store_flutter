import '../../../../core/errors/result.dart';
import '../entities/wallet_summary.dart';
import '../repositories/wallet_repository.dart';

class GetWalletSummaryUseCase {
  const GetWalletSummaryUseCase(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletSummary>> call() => _repository.getWalletSummary();
}
