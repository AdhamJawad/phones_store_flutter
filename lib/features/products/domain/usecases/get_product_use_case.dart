import '../../../../core/errors/result.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductUseCase {
  const GetProductUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<Product>> call(int productId) => _repository.getProduct(productId);
}
