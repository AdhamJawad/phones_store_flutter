import '../../../../core/errors/result.dart';
import '../../../../core/utils/unit.dart';
import '../../../products/domain/entities/product.dart';

import '../entities/create_listing_input.dart';
import '../entities/seller_dashboard.dart';
import '../entities/seller_dashboard_stats.dart';
import '../entities/seller_listings_page.dart';
import '../entities/update_listing_input.dart';

abstract class SellerMarketplaceRepository {
  Future<Result<SellerDashboardStats>> getDashboardStats();

  Future<Result<SellerListingsPage>> getListings({
    int page = 1,
  });

  Future<Result<SellerDashboard>> getDashboard();

  Future<Result<Product>> createListing(CreateListingInput input);

  Future<Result<Product>> updateListing(
    int productId,
    UpdateListingInput input,
  );

  Future<Result<Unit>> deleteListing(int productId);
}
