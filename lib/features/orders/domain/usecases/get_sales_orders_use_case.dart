import '../../../../core/errors/result.dart';
import '../entities/order_page.dart';
import '../repositories/orders_repository.dart';

class GetSalesOrdersUseCase {
  const GetSalesOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<OrderPage>> call({int page = 1}) {
    return _repository.getSalesOrders(page: page);
  }
}
