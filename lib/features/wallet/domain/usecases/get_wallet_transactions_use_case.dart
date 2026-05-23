import '../../../../core/errors/result.dart';
import '../entities/wallet_transaction_page.dart';
import '../repositories/wallet_repository.dart';

class GetWalletTransactionsUseCase {
  const GetWalletTransactionsUseCase(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletTransactionPage>> call({int page = 1}) {
    return _repository.getTransactions(page: page);
  }
}
