import '../../../../core/errors/result.dart';
import '../entities/create_order_input.dart';
import '../entities/order.dart';
import '../entities/order_page.dart';

abstract class OrdersRepository {
  Future<Result<Order>> createOrder(CreateOrderInput input);

  Future<Result<OrderPage>> getBuyerOrders({
    int page = 1,
  });

  Future<Result<Order>> getOrderDetails(int orderId);

  Future<Result<OrderPage>> getSalesOrders({
    int page = 1,
  });

  Future<Result<Order>> approveSalesOrder(int orderId);

  Future<Result<Order>> rejectSalesOrder(int orderId);
}
