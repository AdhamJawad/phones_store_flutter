import '../../../../core/errors/result.dart';
import '../entities/search_results.dart';
import '../repositories/products_repository.dart';

class SearchCatalogUseCase {
  const SearchCatalogUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<SearchResults>> call({
    required String query,
    int page = 1,
  }) {
    return _repository.search(query: query, page: page);
  }
}
