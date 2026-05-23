import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/product_details.dart';

abstract class ProductDetailsRepository {
  Future<Result<ProductDetails>> getProductDetails(int productId);

  Future<Result<List<Product>>> getRelatedProducts({
    required int productId,
    required int categoryId,
  });
}
