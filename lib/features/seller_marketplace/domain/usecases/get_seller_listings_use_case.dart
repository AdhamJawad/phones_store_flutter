import '../../../../core/errors/result.dart';
import '../entities/seller_listings_page.dart';
import '../repositories/seller_marketplace_repository.dart';

class GetSellerListingsUseCase {
  const GetSellerListingsUseCase(this._repository);

  final SellerMarketplaceRepository _repository;

  Future<Result<SellerListingsPage>> call({
    int page = 1,
  }) {
    return _repository.getListings(page: page);
  }
}
