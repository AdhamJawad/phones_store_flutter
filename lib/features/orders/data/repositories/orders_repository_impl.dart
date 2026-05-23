import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/create_order_input.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_page.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/create_order_request_model.dart';

class OrdersRepositoryImpl extends BaseRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({
    required NetworkHandler networkHandler,
    required OrdersRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Order>> approveSalesOrder(int orderId) {
    return guard(() => _remoteDataSource.approveSalesOrder(orderId));
  }

  @override
  Future<Result<Order>> createOrder(CreateOrderInput input) {
    return guard(
      () => _remoteDataSource.createOrder(CreateOrderRequestModel(input)),
    );
  }

  @override
  Future<Result<OrderPage>> getBuyerOrders({int page = 1}) {
    return guard(() => _remoteDataSource.getBuyerOrders(page: page));
  }

  @override
  Future<Result<Order>> getOrderDetails(int orderId) {
    return guard(() => _remoteDataSource.getOrderDetails(orderId));
  }

  @override
  Future<Result<OrderPage>> getSalesOrders({int page = 1}) {
    return guard(() => _remoteDataSource.getSalesOrders(page: page));
  }

  @override
  Future<Result<Order>> rejectSalesOrder(int orderId) {
    return guard(() => _remoteDataSource.rejectSalesOrder(orderId));
  }
}
