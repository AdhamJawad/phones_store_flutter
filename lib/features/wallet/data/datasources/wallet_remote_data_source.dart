import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/parsers/api_response_parser.dart';
import '../models/recharge_request_model.dart';
import '../models/recharge_request_page_model.dart';
import '../models/wallet_summary_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/wallet_transaction_page_model.dart';

class WalletRemoteDataSource {
  const WalletRemoteDataSource(this._dio);

  final Dio _dio;

  Future<WalletSummaryModel> getWalletSummary() async {
    final response = await _dio.get<dynamic>(ApiPaths.wallet);
    ApiResponseParser.ensureSuccessStatus(response);

    final payload = ApiResponseParser.parseData<Map<String, dynamic>>(
      response,
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed wallet summary response.');
    }

    return WalletSummaryModel.fromJson(payload);
  }

  Future<WalletTransactionPageModel> getTransactions({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.walletTransactions,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final envelope = ApiResponseParser.parseEnvelope<List<WalletTransactionModel>>(
      response,
      (json) => _parseTransactions(json),
    );

    return WalletTransactionPageModel.fromEnvelope(
      items: envelope.data ?? const <WalletTransactionModel>[],
      meta: envelope.meta,
    );
  }

  Future<RechargeRequestPageModel> getRechargeRequests({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.walletRechargeRequests,
      queryParameters: <String, dynamic>{'page': page},
    );
    ApiResponseParser.ensureSuccessStatus(response);
    final envelope = ApiResponseParser.parseEnvelope<List<RechargeRequestModel>>(
      response,
      (json) => _parseRechargeRequests(json),
    );

    return RechargeRequestPageModel.fromEnvelope(
      items: envelope.data ?? const <RechargeRequestModel>[],
      meta: envelope.meta,
    );
  }

  Future<RechargeRequestModel> createRechargeRequest({
    required double amount,
    required String method,
    String? proofFilePath,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'amount': amount,
      'method': method,
      if (proofFilePath != null && proofFilePath.trim().isNotEmpty)
        'proof': await MultipartFile.fromFile(proofFilePath),
    });

    final response = await _dio.post<dynamic>(
      ApiPaths.walletRechargeRequests,
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
      (json) => _asMap(json),
    );

    if (payload.isEmpty) {
      throw const UnknownException('Malformed recharge request response.');
    }

    return RechargeRequestModel.fromJson(payload);
  }

  List<WalletTransactionModel> _parseTransactions(Object? raw) {
    if (raw is! List) {
      return const <WalletTransactionModel>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) => WalletTransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  List<RechargeRequestModel> _parseRechargeRequests(Object? raw) {
    if (raw is! List) {
      return const <RechargeRequestModel>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) => RechargeRequestModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
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
