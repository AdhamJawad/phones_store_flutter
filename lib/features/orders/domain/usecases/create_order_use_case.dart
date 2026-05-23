import '../../../../core/errors/result.dart';
import '../entities/create_order_input.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class CreateOrderUseCase {
  const CreateOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<Order>> call(CreateOrderInput input) {
    return _repository.createOrder(input);
  }
}
