import '../../../../core/errors/result.dart';
import '../entities/product_page.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductPage>> call({
    int page = 1,
    String? source,
    int? categoryId,
    String? status,
  }) {
    return _repository.getProducts(
      page: page,
      source: source,
      categoryId: categoryId,
      status: status,
    );
  }
}
