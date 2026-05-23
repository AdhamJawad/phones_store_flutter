import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl extends BaseRepositoryImpl
    implements ProductsRepository {
  ProductsRepositoryImpl({
    required NetworkHandler networkHandler,
    required ProductsRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Category>>> getCategories() {
    return guard(() => _remoteDataSource.getCategories());
  }

  @override
  Future<Result<Product>> getProduct(int productId) {
    return guard(() => _remoteDataSource.getProduct(productId));
  }

  @override
  Future<Result<ProductPage>> getProducts({
    int page = 1,
    String? source,
    int? categoryId,
    String? status,
  }) {
    return guard(
      () => _remoteDataSource.getProducts(
        page: page,
        source: source,
        categoryId: categoryId,
        status: status,
      ),
    );
  }

  @override
  Future<Result<SearchResults>> search({
    required String query,
    int page = 1,
  }) {
    return guard(() => _remoteDataSource.search(query: query, page: page));
  }
}
