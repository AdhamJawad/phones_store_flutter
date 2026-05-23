import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/unit.dart';
import '../../../home/domain/entities/device_request.dart';
import '../../../home/domain/entities/device_request_page.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../data/datasources/device_requests_remote_data_source.dart';
import '../../data/repositories/device_requests_repository_impl.dart';
import '../../domain/entities/create_device_request_input.dart';
import '../../domain/repositories/device_requests_repository.dart';
import '../../domain/usecases/create_device_request_use_case.dart';
import '../../domain/usecases/get_device_requests_use_case.dart';
import '../../domain/usecases/send_device_offer_use_case.dart';
import '../models/create_device_request_state.dart';
import '../models/device_requests_state.dart';

final deviceRequestsRemoteDataSourceProvider =
    Provider<DeviceRequestsRemoteDataSource>((ref) {
  return DeviceRequestsRemoteDataSource(ref.watch(dioProvider));
});

final deviceRequestsRepositoryProvider = Provider<DeviceRequestsRepository>((ref) {
  return DeviceRequestsRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(deviceRequestsRemoteDataSourceProvider),
  );
});

final getDeviceRequestsUseCaseProvider = Provider<GetDeviceRequestsUseCase>((ref) {
  return GetDeviceRequestsUseCase(ref.watch(deviceRequestsRepositoryProvider));
});

final createDeviceRequestUseCaseProvider =
    Provider<CreateDeviceRequestUseCase>((ref) {
  return CreateDeviceRequestUseCase(ref.watch(deviceRequestsRepositoryProvider));
});

final sendDeviceOfferUseCaseProvider = Provider<SendDeviceOfferUseCase>((ref) {
  return SendDeviceOfferUseCase(ref.watch(deviceRequestsRepositoryProvider));
});

final deviceRequestsControllerProvider =
    NotifierProvider<DeviceRequestsController, DeviceRequestsState>(
  DeviceRequestsController.new,
);

final createDeviceRequestControllerProvider = NotifierProvider.autoDispose<
    CreateDeviceRequestController, CreateDeviceRequestState>(
  CreateDeviceRequestController.new,
);

class DeviceRequestsController extends Notifier<DeviceRequestsState> {
  GetDeviceRequestsUseCase get _getDeviceRequestsUseCase =>
      ref.read(getDeviceRequestsUseCaseProvider);
  SendDeviceOfferUseCase get _sendDeviceOfferUseCase =>
      ref.read(sendDeviceOfferUseCaseProvider);

  @override
  DeviceRequestsState build() {
    Future.microtask(load);
    return const DeviceRequestsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getDeviceRequestsUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getDeviceRequestsUseCase();
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
    final result = await _getDeviceRequestsUseCase(page: nextPage);
    _handlePageResult(result, replace: false);
  }

  Future<Result<Unit>> sendOffer(int deviceRequestId) async {
    if (state.offeringIds.contains(deviceRequestId)) {
      return const Success(Unit.value);
    }
    state = state.copyWith(
      offeringIds: {...state.offeringIds, deviceRequestId},
      clearError: true,
      clearFailure: true,
    );
    final result = await _sendDeviceOfferUseCase(deviceRequestId);
    final offeringIds = {...state.offeringIds}..remove(deviceRequestId);
    switch (result) {
      case Success<Unit>():
        state = state.copyWith(offeringIds: offeringIds);
        ref.invalidate(notificationsControllerProvider);
      case Error<Unit>(:final failure):
        state = state.copyWith(
          offeringIds: offeringIds,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
    return result;
  }

  void _handlePageResult(
    Result<DeviceRequestPage> result, {
    required bool replace,
  }) {
    switch (result) {
      case Success<DeviceRequestPage>(:final data):
        state = DeviceRequestsState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          offeringIds: state.offeringIds,
          meta: data.meta,
        );
      case Error<DeviceRequestPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }
}

class CreateDeviceRequestController
    extends AutoDisposeNotifier<CreateDeviceRequestState> {
  CreateDeviceRequestUseCase get _createDeviceRequestUseCase =>
      ref.read(createDeviceRequestUseCaseProvider);

  @override
  CreateDeviceRequestState build() {
    return const CreateDeviceRequestState.initial();
  }

  Future<Result<DeviceRequest>> submit(CreateDeviceRequestInput input) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFailure: true,
      clearCreatedRequest: true,
    );

    final result = await _createDeviceRequestUseCase(input);
    switch (result) {
      case Success<DeviceRequest>(:final data):
        state = state.copyWith(
          isSubmitting: false,
          createdRequest: data,
        );
        ref.invalidate(deviceRequestsControllerProvider);
        ref.invalidate(homeControllerProvider);
      case Error<DeviceRequest>(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
    return result;
  }
}

String _mapFailure(Failure failure) {
  return switch (failure) {
    ValidationFailure() => failure.message,
    UnauthorizedFailure() =>
      'يجب تسجيل الدخول للوصول إلى طلبات الأجهزة.',
    ForbiddenFailure() =>
      'ليس لديك صلاحية لتنفيذ هذا الإجراء.',
    NetworkFailure() =>
      'تعذر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مرة أخرى.',
    CacheFailure() => 'تعذر قراءة البيانات المحلية.',
    ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
    UnknownFailure() => failure.message.isEmpty
        ? 'حدث خطأ غير متوقع أثناء تنفيذ الطلب.'
        : failure.message,
  };
}
