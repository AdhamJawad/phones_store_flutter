import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/products_remote_data_source.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/get_categories_use_case.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../../domain/usecases/search_catalog_use_case.dart';
import '../models/products_query.dart';
import '../models/products_state.dart';

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductsRemoteDataSource(dio);
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(productsRemoteDataSourceProvider),
  );
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(productsRepositoryProvider));
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productsRepositoryProvider));
});

final searchCatalogUseCaseProvider = Provider<SearchCatalogUseCase>((ref) {
  return SearchCatalogUseCase(ref.watch(productsRepositoryProvider));
});

final catalogCategoriesProvider =
    AsyncNotifierProvider<CatalogCategoriesController, List<Category>>(
      CatalogCategoriesController.new,
    );

final productsControllerProvider = NotifierProvider.family<
    ProductsController,
    ProductsState,
    ProductsQuery>(ProductsController.new);

class CatalogCategoriesController extends AsyncNotifier<List<Category>> {
  GetCategoriesUseCase get _getCategoriesUseCase =>
      ref.read(getCategoriesUseCaseProvider);

  @override
  Future<List<Category>> build() async {
    final result = await _getCategoriesUseCase();
    return switch (result) {
      Success<List<Category>>(:final data) => data,
      Error<List<Category>>() => const <Category>[],
    };
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _getCategoriesUseCase();
      return switch (result) {
        Success<List<Category>>(:final data) => data,
        Error<List<Category>>() => const <Category>[],
      };
    });
  }
}

class ProductsController extends FamilyNotifier<ProductsState, ProductsQuery> {
  GetProductsUseCase get _getProductsUseCase => ref.read(getProductsUseCaseProvider);

  @override
  ProductsState build(ProductsQuery arg) {
    Future.microtask(load);
    return ProductsState.initial(
      source: arg.source,
      categoryId: arg.categoryId,
      categoryName: arg.categoryName,
    );
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      isRefreshing: false,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getProductsUseCase(
      page: 1,
      source: state.selectedSource,
      categoryId: state.selectedCategoryId,
    );

    switch (result) {
      case Success<ProductPage>(:final data):
        state = ProductsState(
          items: data.items,
          isLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          selectedSource: state.selectedSource,
          selectedCategoryId: state.selectedCategoryId,
          selectedCategoryName: state.selectedCategoryName,
          meta: data.meta,
        );
      case Error<ProductPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
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

    final result = await _getProductsUseCase(
      page: 1,
      source: state.selectedSource,
      categoryId: state.selectedCategoryId,
    );

    switch (result) {
      case Success<ProductPage>(:final data):
        state = ProductsState(
          items: data.items,
          isLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          selectedSource: state.selectedSource,
          selectedCategoryId: state.selectedCategoryId,
          selectedCategoryName: state.selectedCategoryName,
          meta: data.meta,
        );
      case Error<ProductPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    final nextPage = (state.meta?.currentPage ?? 1) + 1;
    state = state.copyWith(
      isLoadingMore: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getProductsUseCase(
      page: nextPage,
      source: state.selectedSource,
      categoryId: state.selectedCategoryId,
    );

    switch (result) {
      case Success<ProductPage>(:final data):
        state = state.copyWith(
          items: [...state.items, ...data.items],
          isLoadingMore: false,
          meta: data.meta,
        );
      case Error<ProductPage>(:final failure):
        state = state.copyWith(
          isLoadingMore: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  Future<void> setSource(String? source) async {
    state = state.copyWith(
      selectedSource: source,
      isLoading: true,
      isLoadingMore: false,
      clearFailure: true,
      clearError: true,
    );
    await load();
  }

  Future<void> setCategory({
    required int? categoryId,
    required String? categoryName,
  }) async {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      selectedCategoryName: categoryName,
      isLoading: true,
      isLoadingMore: false,
      clearFailure: true,
      clearError: true,
    );
    await load();
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      NetworkFailure() => 'تعذر تحميل المنتجات. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() => 'لا يمكن إكمال الطلب الحالي. حاول تسجيل الدخول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذه البيانات.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل المنتجات.'
          : failure.message,
    };
  }
}
