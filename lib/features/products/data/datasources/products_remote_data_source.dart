import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';
import '../models/search_results_model.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<dynamic>(ApiPaths.categories);
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<List<CategoryModel>>(
      response,
      (json) => _parseCategoryList(json),
    );

    return payload;
  }

  Future<ProductPageModel> getProducts({
    int page = 1,
    String? source,
    int? categoryId,
    String? status,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.products,
      queryParameters: <String, dynamic>{
        'page': page,
        ...?source == null || source.isEmpty
            ? null
            : <String, dynamic>{'source': source},
        ...?categoryId == null
            ? null
            : <String, dynamic>{'category_id': categoryId},
        ...?status == null || status.isEmpty
            ? null
            : <String, dynamic>{'status': status},
      },
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final envelope = ApiResponseParser.parseEnvelope<List<ProductModel>>(
      response,
      (json) => _parseProductList(json),
    );

    return ProductPageModel(
      items: envelope.data ?? const <ProductModel>[],
      meta: envelope.meta == null
          ? const PaginatedResponseMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
              hasMorePages: false,
            )
          : PaginatedResponseMeta.fromJson(envelope.meta!),
    );
  }

  Future<ProductModel> getProduct(int productId) async {
    final response = await _dio.get<dynamic>('${ApiPaths.products}/$productId');
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed product response.');
    }

    return ProductModel.fromJson(payload);
  }

  Future<SearchResultsModel> search({
    required String query,
    int page = 1,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.search,
      queryParameters: <String, dynamic>{
        'q': query,
        'page': page,
      },
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty && query.trim().isNotEmpty) {
      throw const UnknownException('Malformed search response.');
    }

    return SearchResultsModel.fromJson(payload);
  }

  List<CategoryModel> _parseCategoryList(Object? raw) {
    if (raw is! List) {
      return const <CategoryModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<ProductModel> _parseProductList(Object? raw) {
    if (raw is! List) {
      return const <ProductModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }
}
