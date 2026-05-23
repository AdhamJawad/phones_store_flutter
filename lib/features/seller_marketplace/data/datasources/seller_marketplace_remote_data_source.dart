import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../../../products/data/models/product_model.dart';
import '../models/seller_dashboard_stats_model.dart';
import '../models/seller_listings_page_model.dart';

class SellerMarketplaceRemoteDataSource {
  const SellerMarketplaceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SellerDashboardStatsModel> getDashboardStats() async {
    final response = await _dio.get<dynamic>(ApiPaths.meDashboard);
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed seller dashboard response.');
    }

    return SellerDashboardStatsModel.fromJson(payload);
  }

  Future<SellerListingsPageModel> getListings({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.meListings,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final envelope = ApiResponseParser.parseEnvelope<List<ProductModel>>(
      response,
      (json) => _parseProducts(json),
    );

    return SellerListingsPageModel.fromEnvelope(
      items: envelope.data ?? const <ProductModel>[],
      meta: envelope.meta,
    );
  }

  Future<ProductModel> createListing(FormData formData) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.meListings,
      data: formData,
      options: Options(
        headers: const <String, dynamic>{
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );
    if (payload.isEmpty) {
      throw const UnknownException('Malformed listing response.');
    }
    return ProductModel.fromJson(payload);
  }

  Future<ProductModel> updateListing(int productId, FormData formData) async {
    final response = await _dio.post<dynamic>(
      '${ApiPaths.meListings}/$productId/update',
      data: formData,
      options: Options(
        headers: const <String, dynamic>{
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      _asMap,
    );
    if (payload.isEmpty) {
      throw const UnknownException('Malformed listing response.');
    }
    return ProductModel.fromJson(payload);
  }

  Future<void> deleteListing(int productId) async {
    final response = await _dio.delete<dynamic>('${ApiPaths.meListings}/$productId');
    ApiResponseParser.ensureSuccessStatus(response);
  }

  List<ProductModel> _parseProducts(Object? raw) {
    if (raw is! List) {
      return const <ProductModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const <String, dynamic>{};
  }
}
