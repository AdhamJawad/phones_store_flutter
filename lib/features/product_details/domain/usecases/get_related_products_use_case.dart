import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/product_details_repository.dart';

class GetRelatedProductsUseCase {
  const GetRelatedProductsUseCase(this._repository);

  final ProductDetailsRepository _repository;

  Future<Result<List<Product>>> call({
    required int productId,
    required int categoryId,
  }) {
    return _repository.getRelatedProducts(
      productId: productId,
      categoryId: categoryId,
    );
  }
}
