import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../repositories/seller_marketplace_repository.dart';

class DeleteListingUseCase {
  const DeleteListingUseCase(this._repository);

  final SellerMarketplaceRepository _repository;

  Future<Result<Unit>> call(int productId) {
    return _repository.deleteListing(productId);
  }
}
