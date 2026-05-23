import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../product_details/presentation/providers/product_details_providers.dart';
import '../../data/datasources/orders_remote_data_source.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/create_order_input.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_page.dart';
import '../../domain/entities/order_payment_method.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/usecases/approve_sales_order_use_case.dart';
import '../../domain/usecases/create_order_use_case.dart';
import '../../domain/usecases/get_buyer_orders_use_case.dart';
import '../../domain/usecases/get_order_details_use_case.dart';
import '../../domain/usecases/get_sales_orders_use_case.dart';
import '../../domain/usecases/reject_sales_order_use_case.dart';
import '../models/create_order_state.dart';
import '../models/order_details_state.dart';
import '../models/orders_list_state.dart';

final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSource(ref.watch(dioProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(ordersRemoteDataSourceProvider),
  );
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.watch(ordersRepositoryProvider));
});

final getBuyerOrdersUseCaseProvider = Provider<GetBuyerOrdersUseCase>((ref) {
  return GetBuyerOrdersUseCase(ref.watch(ordersRepositoryProvider));
});

final getOrderDetailsUseCaseProvider = Provider<GetOrderDetailsUseCase>((ref) {
  return GetOrderDetailsUseCase(ref.watch(ordersRepositoryProvider));
});

final getSalesOrdersUseCaseProvider = Provider<GetSalesOrdersUseCase>((ref) {
  return GetSalesOrdersUseCase(ref.watch(ordersRepositoryProvider));
});

final approveSalesOrderUseCaseProvider =
    Provider<ApproveSalesOrderUseCase>((ref) {
  return ApproveSalesOrderUseCase(ref.watch(ordersRepositoryProvider));
});

final rejectSalesOrderUseCaseProvider =
    Provider<RejectSalesOrderUseCase>((ref) {
  return RejectSalesOrderUseCase(ref.watch(ordersRepositoryProvider));
});

final createOrderControllerProvider = NotifierProvider.autoDispose<
    CreateOrderController, CreateOrderState>(CreateOrderController.new);

final buyerOrdersControllerProvider =
    NotifierProvider<BuyerOrdersController, OrdersListState>(
  BuyerOrdersController.new,
);

final salesOrdersControllerProvider =
    NotifierProvider<SalesOrdersController, OrdersListState>(
  SalesOrdersController.new,
);

final orderDetailsControllerProvider =
    NotifierProvider.family<OrderDetailsController, OrderDetailsState, int>(
  OrderDetailsController.new,
);

class CreateOrderController extends AutoDisposeNotifier<CreateOrderState> {
  CreateOrderUseCase get _createOrderUseCase => ref.read(createOrderUseCaseProvider);

  @override
  CreateOrderState build() {
    return CreateOrderState.initial(
      paymentMethod: OrderPaymentMethod.cod,
    );
  }

  void setPaymentMethod(OrderPaymentMethod value) {
    state = state.copyWith(
      paymentMethod: value,
      clearError: true,
      clearFailure: true,
    );
  }

  Future<Result<Order>> submit(CreateOrderInput input) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFailure: true,
      clearCreatedOrder: true,
    );

    final result = await _createOrderUseCase(input);
    switch (result) {
      case Success<Order>(:final data):
        state = state.copyWith(
          isSubmitting: false,
          createdOrder: data,
        );
        ref.invalidate(buyerOrdersControllerProvider);
        ref.invalidate(salesOrdersControllerProvider);
        ref.invalidate(productDetailsControllerProvider(input.productId));
      case Error<Order>(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }

    return result;
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'يجب تسجيل الدخول لإتمام الطلب.',
      ForbiddenFailure() => 'ليس لديك صلاحية لإتمام هذا الإجراء.',
      NetworkFailure() => 'تعذر إرسال الطلب. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة بعض البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء إنشاء الطلب.'
          : failure.message,
    };
  }
}

class BuyerOrdersController extends Notifier<OrdersListState> {
  GetBuyerOrdersUseCase get _getBuyerOrdersUseCase =>
      ref.read(getBuyerOrdersUseCaseProvider);

  @override
  OrdersListState build() {
    Future.microtask(load);
    return const OrdersListState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      isRefreshing: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getBuyerOrdersUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getBuyerOrdersUseCase();
    _handlePageResult(result, replace: true, fromRefresh: true);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore || state.isLoading) {
      return;
    }
    final nextPage = (state.meta?.currentPage ?? 1) + 1;
    state = state.copyWith(
      isLoadingMore: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getBuyerOrdersUseCase(page: nextPage);
    _handlePageResult(result, replace: false);
  }

  void _handlePageResult(
    Result<OrderPage> result, {
    required bool replace,
    bool fromRefresh = false,
  }) {
    switch (result) {
      case Success<OrderPage>(:final data):
        state = OrdersListState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          meta: data.meta,
        );
      case Error<OrderPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: _mapFailure(failure),
          failure: failure,
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'يجب تسجيل الدخول لعرض الطلبات.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذه الطلبات.',
      NetworkFailure() => 'تعذر تحميل الطلبات. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل الطلبات.'
          : failure.message,
    };
  }
}

class SalesOrdersController extends Notifier<OrdersListState> {
  GetSalesOrdersUseCase get _getSalesOrdersUseCase =>
      ref.read(getSalesOrdersUseCaseProvider);

  ApproveSalesOrderUseCase get _approveSalesOrderUseCase =>
      ref.read(approveSalesOrderUseCaseProvider);

  RejectSalesOrderUseCase get _rejectSalesOrderUseCase =>
      ref.read(rejectSalesOrderUseCaseProvider);

  @override
  OrdersListState build() {
    Future.microtask(load);
    return const OrdersListState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getSalesOrdersUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getSalesOrdersUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore || state.isLoading) {
      return;
    }
    final nextPage = (state.meta?.currentPage ?? 1) + 1;
    state = state.copyWith(
      isLoadingMore: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getSalesOrdersUseCase(page: nextPage);
    _handlePageResult(result, replace: false);
  }

  Future<Result<Order>> approve(int orderId) async {
    final result = await _approveSalesOrderUseCase(orderId);
    return _applyActionResult(result);
  }

  Future<Result<Order>> reject(int orderId) async {
    final result = await _rejectSalesOrderUseCase(orderId);
    return _applyActionResult(result);
  }

  Result<Order> _applyActionResult(Result<Order> result) {
    switch (result) {
      case Success<Order>(:final data):
        final items = state.items
            .map((order) => order.id == data.id ? data : order)
            .toList(growable: false);
        state = state.copyWith(items: items);
      case Error<Order>(:final failure):
        state = state.copyWith(
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
    return result;
  }

  void _handlePageResult(
    Result<OrderPage> result, {
    required bool replace,
  }) {
    switch (result) {
      case Success<OrderPage>(:final data):
        state = OrdersListState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          meta: data.meta,
        );
      case Error<OrderPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: _mapFailure(failure),
          failure: failure,
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'يجب تسجيل الدخول لعرض طلبات المبيعات.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى طلبات المبيعات.',
      NetworkFailure() => 'تعذر تحميل طلبات المبيعات. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل طلبات المبيعات.'
          : failure.message,
    };
  }
}

class OrderDetailsController extends FamilyNotifier<OrderDetailsState, int> {
  GetOrderDetailsUseCase get _getOrderDetailsUseCase =>
      ref.read(getOrderDetailsUseCaseProvider);

  @override
  OrderDetailsState build(int arg) {
    Future.microtask(load);
    return const OrderDetailsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getOrderDetailsUseCase(arg);
    switch (result) {
      case Success<Order>(:final data):
        state = OrderDetailsState(
          isLoading: false,
          isRefreshing: false,
          order: data,
        );
      case Error<Order>(:final failure):
        state = OrderDetailsState(
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getOrderDetailsUseCase(arg);
    switch (result) {
      case Success<Order>(:final data):
        state = OrderDetailsState(
          isLoading: false,
          isRefreshing: false,
          order: data,
        );
      case Error<Order>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'يجب تسجيل الدخول لعرض تفاصيل الطلب.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذا الطلب.',
      NetworkFailure() => 'تعذر تحميل تفاصيل الطلب. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل تفاصيل الطلب.'
          : failure.message,
    };
  }
}
