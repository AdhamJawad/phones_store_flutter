import '../../../../core/errors/result.dart';
import '../entities/seller_dashboard.dart';
import '../repositories/seller_marketplace_repository.dart';

class GetSellerDashboardUseCase {
  const GetSellerDashboardUseCase(this._repository);

  final SellerMarketplaceRepository _repository;

  Future<Result<SellerDashboard>> call() {
    return _repository.getDashboard();
  }
}
