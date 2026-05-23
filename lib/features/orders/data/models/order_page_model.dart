import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/order_page.dart';
import 'order_model.dart';

class OrderPageModel extends OrderPage {
  const OrderPageModel({
    required super.items,
    required super.meta,
  });

  factory OrderPageModel.fromEnvelope({
    required List<OrderModel> items,
    Map<String, dynamic>? meta,
  }) {
    return OrderPageModel(
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
