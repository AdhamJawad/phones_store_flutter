import '../../../products/domain/entities/product.dart';
import 'product_details.dart';

class ProductDetailsPayload {
  const ProductDetailsPayload({
    required this.details,
    required this.relatedProducts,
  });

  final ProductDetails details;
  final List<Product> relatedProducts;
}
