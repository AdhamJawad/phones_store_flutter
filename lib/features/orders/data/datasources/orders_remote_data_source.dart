import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/create_order_request_model.dart';
import '../models/order_model.dart';
import '../models/order_page_model.dart';

class OrdersRemoteDataSource {
  const OrdersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<OrderModel> createOrder(CreateOrderRequestModel request) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.orders,
      data: request.toJson(),
    );
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed order creation response.');
    }

    return OrderModel.fromJson(payload);
  }

  Future<OrderPageModel> getBuyerOrders({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.orders,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final envelope = ApiResponseParser.parseEnvelope<List<OrderModel>>(
      response,
      (json) => _parseOrders(json),
    );

    return OrderPageModel.fromEnvelope(
      items: envelope.data ?? const <OrderModel>[],
      meta: envelope.meta,
    );
  }

  Future<OrderModel> getOrderDetails(int orderId) async {
    final response = await _dio.get<dynamic>('${ApiPaths.orders}/$orderId');
    ApiResponseParser.ensureSuccessStatus(response);
    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed order details response.');
    }

    return OrderModel.fromJson(payload);
  }

  Future<OrderPageModel> getSalesOrders({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.salesOrders,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final envelope = ApiResponseParser.parseEnvelope<List<OrderModel>>(
      response,
      (json) => _parseOrders(json),
    );

    return OrderPageModel.fromEnvelope(
      items: envelope.data ?? const <OrderModel>[],
      meta: envelope.meta,
    );
  }

  Future<OrderModel> approveSalesOrder(int orderId) async {
    return _postSalesAction(
      '${ApiPaths.salesOrders}/$orderId/approve',
    );
  }

  Future<OrderModel> rejectSalesOrder(int orderId) async {
    return _postSalesAction(
      '${ApiPaths.salesOrders}/$orderId/reject',
    );
  }

  Future<OrderModel> _postSalesAction(String path) async {
    final response = await _dio.post<dynamic>(path);
    ApiResponseParser.ensureSuccessStatus(response);
    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );
    if (payload.isEmpty) {
      throw const UnknownException('Malformed sales order response.');
    }

    return OrderModel.fromJson(payload);
  }

  List<OrderModel> _parseOrders(Object? raw) {
    if (raw is! List) {
      return const <OrderModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
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
