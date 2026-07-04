import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../device_catalog/domain/entities/device.dart';
import '../../../device_catalog/domain/entities/device_page.dart';
import '../../../device_catalog/presentation/providers/device_catalog_providers.dart';
import '../../data/datasources/device_compare_remote_data_source.dart';
import '../../data/repositories/device_compare_repository_impl.dart';
import '../../domain/entities/device_comparison.dart';
import '../../domain/repositories/device_compare_repository.dart';
import '../../domain/usecases/compare_devices_use_case.dart';
import '../models/device_compare_result_state.dart';
import '../models/device_compare_state.dart';

final deviceCompareRemoteDataSourceProvider =
    Provider<DeviceCompareRemoteDataSource>((ref) {
      return DeviceCompareRemoteDataSource(ref.watch(dioProvider));
    });

final deviceCompareRepositoryProvider = Provider<DeviceCompareRepository>((
  ref,
) {
  return DeviceCompareRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(deviceCompareRemoteDataSourceProvider),
  );
});

final compareDevicesUseCaseProvider = Provider<CompareDevicesUseCase>((ref) {
  return CompareDevicesUseCase(ref.watch(deviceCompareRepositoryProvider));
});

final deviceCompareControllerProvider =
    NotifierProvider<DeviceCompareController, DeviceCompareState>(
      DeviceCompareController.new,
    );

final deviceCompareResultControllerProvider =
    NotifierProvider.family<
      DeviceCompareResultController,
      DeviceCompareResultState,
      String
    >(DeviceCompareResultController.new);

class DeviceCompareController extends Notifier<DeviceCompareState> {
  @override
  DeviceCompareState build() {
    Future.microtask(loadOptions);
    return const DeviceCompareState.initial();
  }

  Future<void> loadOptions() async {
    state = state.copyWith(
      isLoadingOptions: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await ref.read(getDevicesUseCaseProvider)(
      page: 1,
      perPage: 50,
    );

    switch (result) {
      case Success<DevicePage>(:final data):
        final items = data.items;
        state = state.copyWith(
          availableDevices: items,
          filteredDevices: _filterDevices(items, state.searchQuery),
          isLoadingOptions: false,
        );
      case Error<DevicePage>(:final failure):
        state = state.copyWith(
          isLoadingOptions: false,
          failure: failure,
          errorMessage: _mapOptionsFailure(failure),
        );
    }
  }

  void setSearchQuery(String query) {
    final normalizedQuery = query.trim();
    state = state.copyWith(
      searchQuery: normalizedQuery,
      filteredDevices: _filterDevices(state.availableDevices, normalizedQuery),
      clearFailure: true,
      clearError: true,
    );
  }

  void toggleDevice(int deviceId) {
    final selected = [...state.selectedDeviceIds];
    if (selected.contains(deviceId)) {
      selected.remove(deviceId);
    } else {
      if (selected.length == 2) {
        selected.removeAt(0);
      }
      selected.add(deviceId);
    }

    state = state.copyWith(
      selectedDeviceIds: selected,
      clearFailure: true,
      clearError: true,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedDeviceIds: const <int>[],
      clearComparison: true,
      clearFailure: true,
      clearError: true,
    );
  }

  List<Device> _filterDevices(List<Device> devices, String query) {
    if (query.isEmpty) {
      return devices;
    }

    final normalizedQuery = query.toLowerCase();
    return devices
        .where((device) {
          final haystack =
              '${device.brand} ${device.modelName} ${device.name} '
                      '${device.specifications.processor ?? ''} '
                      '${device.specifications.display ?? ''}'
                  .toLowerCase();
          return haystack.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  String _mapOptionsFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      NetworkFailure() => 'تعذر تحميل قائمة الأجهزة للمقارنة.',
      UnauthorizedFailure() => 'تعذر إكمال الطلب الحالي. حاول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذه البيانات.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() =>
        failure.message.isEmpty
            ? 'حدث خطأ غير متوقع أثناء تحميل قائمة الأجهزة.'
            : failure.message,
    };
  }
}

class DeviceCompareResultController
    extends FamilyNotifier<DeviceCompareResultState, String> {
  CompareDevicesUseCase get _compareDevicesUseCase =>
      ref.read(compareDevicesUseCaseProvider);

  @override
  DeviceCompareResultState build(String arg) {
    Future.microtask(load);
    return const DeviceCompareResultState.initial();
  }

  Future<void> load() async {
    final currentComparison = state.comparison;
    state = state.copyWith(
      isLoading: currentComparison == null,
      isRefreshing: false,
      clearFailure: true,
      clearError: true,
    );

    final deviceIds = _parseIds(arg);
    if (deviceIds.length != 2) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر قراءة الأجهزة المطلوبة للمقارنة.',
      );
      return;
    }

    final result = await _compareDevicesUseCase(deviceIds: deviceIds);
    switch (result) {
      case Success<DeviceComparison>(:final data):
        state = DeviceCompareResultState(
          isLoading: false,
          isRefreshing: false,
          comparison: data,
        );
      case Error<DeviceComparison>(:final failure):
        state = DeviceCompareResultState(
          isLoading: false,
          isRefreshing: false,
          comparison: currentComparison,
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
    await load();
  }

  List<int> _parseIds(String value) {
    return value
        .split(',')
        .map((item) => int.tryParse(item.trim()))
        .whereType<int>()
        .toList(growable: false);
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      NetworkFailure() =>
        'تعذر تنفيذ المقارنة. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() => 'تعذر إكمال الطلب الحالي. حاول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذه البيانات.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() =>
        failure.message.isEmpty
            ? 'حدث خطأ غير متوقع أثناء تنفيذ المقارنة.'
            : failure.message,
    };
  }
}
