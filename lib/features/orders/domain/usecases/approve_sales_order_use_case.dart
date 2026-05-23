import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class ApproveSalesOrderUseCase {
  const ApproveSalesOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<Order>> call(int orderId) {
    return _repository.approveSalesOrder(orderId);
  }
}
