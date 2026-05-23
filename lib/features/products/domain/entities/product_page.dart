import '../../../../core/network/dto/paginated_response_meta.dart';
import 'product.dart';

class ProductPage {
  const ProductPage({
    required this.items,
    required this.meta,
  });

  final List<Product> items;
  final PaginatedResponseMeta meta;
}
