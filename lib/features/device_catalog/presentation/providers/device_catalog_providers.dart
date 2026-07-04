import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/device_catalog_remote_data_source.dart';
import '../../data/repositories/device_catalog_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_page.dart';
import '../../domain/repositories/device_catalog_repository.dart';
import '../../domain/usecases/get_device_details_use_case.dart';
import '../../domain/usecases/get_devices_use_case.dart';
import '../models/device_catalog_state.dart';
import '../models/device_details_state.dart';

final deviceCatalogRemoteDataSourceProvider =
    Provider<DeviceCatalogRemoteDataSource>((ref) {
      return DeviceCatalogRemoteDataSource(ref.watch(dioProvider));
    });

final deviceCatalogRepositoryProvider = Provider<DeviceCatalogRepository>((
  ref,
) {
  return DeviceCatalogRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(deviceCatalogRemoteDataSourceProvider),
  );
});

final getDevicesUseCaseProvider = Provider<GetDevicesUseCase>((ref) {
  return GetDevicesUseCase(ref.watch(deviceCatalogRepositoryProvider));
});

final getDeviceDetailsUseCaseProvider = Provider<GetDeviceDetailsUseCase>((
  ref,
) {
  return GetDeviceDetailsUseCase(ref.watch(deviceCatalogRepositoryProvider));
});

final deviceCatalogControllerProvider =
    NotifierProvider<DeviceCatalogController, DeviceCatalogState>(
      DeviceCatalogController.new,
    );

final deviceDetailsControllerProvider =
    NotifierProvider.family<DeviceDetailsController, DeviceDetailsState, int>(
      DeviceDetailsController.new,
    );

class DeviceCatalogController extends Notifier<DeviceCatalogState> {
  static const int _pageSize = 15;

  GetDevicesUseCase get _getDevicesUseCase =>
      ref.read(getDevicesUseCaseProvider);

  @override
  DeviceCatalogState build() {
    Future.microtask(load);
    return const DeviceCatalogState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      isRefreshing: false,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getDevicesUseCase(
      page: 1,
      perPage: _pageSize,
      query: state.query,
      brand: state.selectedBrand,
    );

    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = state.copyWith(
      isRefreshing: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getDevicesUseCase(
      page: 1,
      perPage: _pageSize,
      query: state.query,
      brand: state.selectedBrand,
    );

    _handlePageResult(result, replace: true);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoading || state.isLoadingMore) {
      return;
    }

    final nextPage = (state.meta?.currentPage ?? 1) + 1;
    state = state.copyWith(
      isLoadingMore: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getDevicesUseCase(
      page: nextPage,
      perPage: _pageSize,
      query: state.query,
      brand: state.selectedBrand,
    );

    _handlePageResult(result, replace: false);
  }

  Future<void> submitSearch(String query) async {
    state = state.copyWith(
      query: query.trim(),
      isLoading: true,
      isLoadingMore: false,
      clearFailure: true,
      clearError: true,
    );
    await load();
  }

  Future<void> clearSearch() async {
    state = state.copyWith(
      query: '',
      isLoading: true,
      isLoadingMore: false,
      clearFailure: true,
      clearError: true,
    );
    await load();
  }

  Future<void> setBrand(String? brand) async {
    final normalizedBrand = brand?.trim();
    final shouldClearBrand = normalizedBrand == null || normalizedBrand.isEmpty;
    state = state.copyWith(
      selectedBrand: shouldClearBrand ? null : normalizedBrand,
      isLoading: true,
      isLoadingMore: false,
      clearBrand: shouldClearBrand,
      clearFailure: true,
      clearError: true,
    );
    await load();
  }

  void _handlePageResult(Result<DevicePage> result, {required bool replace}) {
    switch (result) {
      case Success<DevicePage>(:final data):
        final mergedItems = replace
            ? data.items
            : [...state.items, ...data.items];
        final extractedBrands = _extractAvailableBrands(mergedItems);
        final shouldPreserveBrandOptions =
            state.availableBrands.isNotEmpty &&
            (state.selectedBrand != null || state.query.isNotEmpty);
        state = DeviceCatalogState(
          items: mergedItems,
          isLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          query: state.query,
          selectedBrand: state.selectedBrand,
          availableBrands: shouldPreserveBrandOptions
              ? state.availableBrands
              : extractedBrands,
          meta: data.meta,
        );
      case Error<DevicePage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  List<String> _extractAvailableBrands(List<Device> items) {
    final brands = items
        .map((device) => device.brand.trim())
        .where((brand) => brand.isNotEmpty)
        .toSet()
        .toList(growable: false);
    brands.sort();
    return brands;
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      NetworkFailure() =>
        'تعذر تحميل كتالوج الأجهزة. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() =>
        'تعذر إكمال الطلب الحالي. حاول تسجيل الدخول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذا المحتوى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() =>
        failure.message.isEmpty
            ? 'حدث خطأ غير متوقع أثناء تحميل الأجهزة.'
            : failure.message,
    };
  }
}

class DeviceDetailsController extends FamilyNotifier<DeviceDetailsState, int> {
  GetDeviceDetailsUseCase get _getDeviceDetailsUseCase =>
      ref.read(getDeviceDetailsUseCaseProvider);

  @override
  DeviceDetailsState build(int arg) {
    Future.microtask(load);
    return const DeviceDetailsState.initial();
  }

  Future<void> load() async {
    final currentDevice = state.device;
    state = state.copyWith(
      isLoading: currentDevice == null,
      isRefreshing: false,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getDeviceDetailsUseCase(arg);

    switch (result) {
      case Success<Device>(:final data):
        state = DeviceDetailsState(
          isLoading: false,
          isRefreshing: false,
          device: data,
        );
      case Error<Device>(:final failure):
        state = DeviceDetailsState(
          isLoading: false,
          isRefreshing: false,
          device: currentDevice,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getDeviceDetailsUseCase(arg);

    switch (result) {
      case Success<Device>(:final data):
        state = DeviceDetailsState(
          isLoading: false,
          isRefreshing: false,
          device: data,
        );
      case Error<Device>(:final failure):
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
      NetworkFailure() =>
        'تعذر تحميل تفاصيل الجهاز. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() =>
        'تعذر إكمال الطلب الحالي. حاول تسجيل الدخول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذا المحتوى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() =>
        failure.message.isEmpty
            ? 'حدث خطأ غير متوقع أثناء تحميل تفاصيل الجهاز.'
            : failure.message,
    };
  }
}
