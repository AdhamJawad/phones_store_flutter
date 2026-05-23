import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../../products/domain/entities/product.dart';

class SellerListingsPage {
  const SellerListingsPage({
    required this.items,
    this.meta,
  });

  final List<Product> items;
  final PaginatedResponseMeta? meta;
}
