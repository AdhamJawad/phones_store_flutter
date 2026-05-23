import '../../../../core/errors/result.dart';
import '../entities/product_details.dart';
import '../repositories/product_details_repository.dart';

class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repository);

  final ProductDetailsRepository _repository;

  Future<Result<ProductDetails>> call(int productId) {
    return _repository.getProductDetails(productId);
  }
}
