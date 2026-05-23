import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/update_listing_input.dart';
import '../repositories/seller_marketplace_repository.dart';

class UpdateListingUseCase {
  const UpdateListingUseCase(this._repository);

  final SellerMarketplaceRepository _repository;

  Future<Result<Product>> call(
    int productId,
    UpdateListingInput input,
  ) {
    return _repository.updateListing(productId, input);
  }
}
