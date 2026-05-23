import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/network/handlers/network_handler.dart';

abstract class BaseRepositoryImpl {
  BaseRepositoryImpl(this.networkHandler);

  final NetworkHandler networkHandler;

  Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      final connected = await networkHandler.isConnected;
      if (!connected) {
        throw const NetworkException();
      }

      final result = await action();
      return Success(result);
    } catch (error) {
      return Error(ExceptionMapper.map(error));
    }
  }
}
