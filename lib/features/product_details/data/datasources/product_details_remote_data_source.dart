import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../../../products/data/models/product_model.dart';

class ProductDetailsRemoteDataSource {
  const ProductDetailsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductModel> getProductDetails(int productId) async {
    final response = await _dio.get<dynamic>('${ApiPaths.products}/$productId');
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed product details response.');
    }

    return ProductModel.fromJson(payload);
  }

  Future<List<ProductModel>> getRelatedProducts({
    required int categoryId,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.products,
      queryParameters: <String, dynamic>{
        'category_id': categoryId,
      },
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<List<ProductModel>>(
      response,
      (json) => _parseProductList(json),
    );

    return payload;
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
