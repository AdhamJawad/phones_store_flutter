import '../../../../core/network/dto/paginated_response_meta.dart';
import 'order.dart';

class OrderPage {
  const OrderPage({
    required this.items,
    required this.meta,
  });

  final List<Order> items;
  final PaginatedResponseMeta meta;
}
