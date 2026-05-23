import '../../../../core/network/dto/paginated_response_meta.dart';
import 'recharge_request.dart';

class RechargeRequestPage {
  const RechargeRequestPage({
    required this.items,
    required this.meta,
  });

  final List<RechargeRequest> items;
  final PaginatedResponseMeta meta;
}
