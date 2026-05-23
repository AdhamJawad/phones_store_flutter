import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/create_listing_input.dart';
import '../repositories/seller_marketplace_repository.dart';

class CreateListingUseCase {
  const CreateListingUseCase(this._repository);

  final SellerMarketplaceRepository _repository;

  Future<Result<Product>> call(CreateListingInput input) {
    return _repository.createListing(input);
  }
}
