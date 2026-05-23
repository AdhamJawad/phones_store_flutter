import '../../../../core/errors/result.dart';
import '../entities/create_recharge_request_input.dart';
import '../entities/recharge_request.dart';
import '../repositories/wallet_repository.dart';

class CreateRechargeRequestUseCase {
  const CreateRechargeRequestUseCase(this._repository);

  final WalletRepository _repository;

  Future<Result<RechargeRequest>> call(CreateRechargeRequestInput input) {
    return _repository.createRechargeRequest(input);
  }
}
