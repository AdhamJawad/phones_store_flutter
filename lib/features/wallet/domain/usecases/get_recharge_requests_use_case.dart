import '../../../../core/errors/result.dart';
import '../entities/recharge_request_page.dart';
import '../repositories/wallet_repository.dart';

class GetRechargeRequestsUseCase {
  const GetRechargeRequestsUseCase(this._repository);

  final WalletRepository _repository;

  Future<Result<RechargeRequestPage>> call({int page = 1}) {
    return _repository.getRechargeRequests(page: page);
  }
}
