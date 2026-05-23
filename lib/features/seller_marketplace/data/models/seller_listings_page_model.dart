import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/seller_listings_page.dart';

class SellerListingsPageModel extends SellerListingsPage {
  const SellerListingsPageModel({
    required super.items,
    super.meta,
  });

  factory SellerListingsPageModel.fromEnvelope({
    required List<ProductModel> items,
    Map<String, dynamic>? meta,
  }) {
    return SellerListingsPageModel(
      items: items,
      meta: meta == null ? null : PaginatedResponseMeta.fromJson(meta),
    );
  }
}
