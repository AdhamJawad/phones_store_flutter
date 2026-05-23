import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_home_feed_use_case.dart';
import '../models/home_state.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRemoteDataSource(dio);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(homeRemoteDataSourceProvider),
  );
});

final getHomeFeedUseCaseProvider = Provider<GetHomeFeedUseCase>((ref) {
  return GetHomeFeedUseCase(ref.watch(homeRepositoryProvider));
});

final homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);

class HomeController extends Notifier<HomeState> {
  GetHomeFeedUseCase get _getHomeFeedUseCase => ref.read(getHomeFeedUseCaseProvider);

  @override
  HomeState build() {
    Future.microtask(load);
    return const HomeState.initial();
  }

  Future<void> load() async {
    final currentFeed = state.feed;
    state = state.copyWith(
      isLoading: currentFeed == null,
      isRefreshing: false,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getHomeFeedUseCase();

    switch (result) {
      case Success<HomeFeed>(:final data):
        state = HomeState(
          isLoading: false,
          isRefreshing: false,
          feed: data,
        );
      case Error<HomeFeed>(:final failure):
        state = HomeState(
          isLoading: false,
          isRefreshing: false,
          feed: currentFeed,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
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

    final result = await _getHomeFeedUseCase();

    switch (result) {
      case Success<HomeFeed>(:final data):
        state = HomeState(
          isLoading: false,
          isRefreshing: false,
          feed: data,
        );
      case Error<HomeFeed>(:final failure):
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
      NetworkFailure() => 'تعذر تحميل الصفحة الرئيسية. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() => 'تعذر إكمال الطلب الحالي. حاول تسجيل الدخول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذا المحتوى.',
      CacheFailure() => 'حدث خطأ أثناء قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل الصفحة الرئيسية.'
          : failure.message,
    };
  }
}
