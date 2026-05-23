import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/recharge_request_page.dart';
import 'recharge_request_model.dart';

class RechargeRequestPageModel extends RechargeRequestPage {
  const RechargeRequestPageModel({
    required super.items,
    required super.meta,
  });

  factory RechargeRequestPageModel.fromEnvelope({
    required List<RechargeRequestModel> items,
    Map<String, dynamic>? meta,
  }) {
    return RechargeRequestPageModel(
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
