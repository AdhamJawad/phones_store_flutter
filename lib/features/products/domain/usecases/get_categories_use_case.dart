import '../../../../core/errors/result.dart';
import '../entities/category.dart';
import '../repositories/products_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<List<Category>>> call() => _repository.getCategories();
}
