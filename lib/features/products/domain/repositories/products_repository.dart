import '../../../../core/errors/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/product_page.dart';
import '../entities/search_results.dart';

abstract class ProductsRepository {
  Future<Result<List<Category>>> getCategories();

  Future<Result<ProductPage>> getProducts({
    int page = 1,
    String? source,
    int? categoryId,
    String? status,
  });

  Future<Result<Product>> getProduct(int productId);

  Future<Result<SearchResults>> search({
    required String query,
    int page = 1,
  });
}
