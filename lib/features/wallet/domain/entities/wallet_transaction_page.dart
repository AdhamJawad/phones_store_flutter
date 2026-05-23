import '../../../../core/network/dto/paginated_response_meta.dart';
import 'wallet_transaction.dart';

class WalletTransactionPage {
  const WalletTransactionPage({
    required this.items,
    required this.meta,
  });

  final List<WalletTransaction> items;
  final PaginatedResponseMeta meta;
}
