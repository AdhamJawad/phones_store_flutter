import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/wallet_transaction_page.dart';
import 'wallet_transaction_model.dart';

class WalletTransactionPageModel extends WalletTransactionPage {
  const WalletTransactionPageModel({
    required super.items,
    required super.meta,
  });

  factory WalletTransactionPageModel.fromEnvelope({
    required List<WalletTransactionModel> items,
    Map<String, dynamic>? meta,
  }) {
    return WalletTransactionPageModel(
      items: items,
      meta: meta == null
          ? const PaginatedResponseMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
              hasMorePages: false,
            )
          : PaginatedResponseMeta.fromJson(meta),
    );
  }
}
