import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../data/datasources/product_details_remote_data_source.dart';
import '../../data/repositories/product_details_repository_impl.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_details_repository.dart';
import '../../domain/usecases/get_product_details_use_case.dart';
import '../../domain/usecases/get_related_products_use_case.dart';
import '../models/product_details_state.dart';

final productDetailsRemoteDataSourceProvider =
    Provider<ProductDetailsRemoteDataSource>((ref) {
  return ProductDetailsRemoteDataSource(ref.watch(dioProvider));
});

final productDetailsRepositoryProvider =
    Provider<ProductDetailsRepository>((ref) {
  return ProductDetailsRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(productDetailsRemoteDataSourceProvider),
  );
});

final getProductDetailsUseCaseProvider =
    Provider<GetProductDetailsUseCase>((ref) {
  return GetProductDetailsUseCase(ref.watch(productDetailsRepositoryProvider));
});

final getRelatedProductsUseCaseProvider =
    Provider<GetRelatedProductsUseCase>((ref) {
  return GetRelatedProductsUseCase(ref.watch(productDetailsRepositoryProvider));
});

final productDetailsControllerProvider = NotifierProvider.family<
    ProductDetailsController, ProductDetailsState, int>(
  ProductDetailsController.new,
);

class ProductDetailsController extends FamilyNotifier<ProductDetailsState, int> {
  GetProductDetailsUseCase get _getProductDetailsUseCase =>
      ref.read(getProductDetailsUseCaseProvider);

  GetRelatedProductsUseCase get _getRelatedProductsUseCase =>
      ref.read(getRelatedProductsUseCaseProvider);

  @override
  ProductDetailsState build(int arg) {
    Future.microtask(load);
    return const ProductDetailsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isRelatedLoading: false,
      clearFailure: true,
      clearError: true,
      clearRelated: true,
    );

    final result = await _getProductDetailsUseCase(arg);

    switch (result) {
      case Success<ProductDetails>(:final data):
        state = ProductDetailsState(
          isLoading: false,
          isRefreshing: false,
          isRelatedLoading: false,
          selectedImageIndex: 0,
          details: data,
          selectedVariantId: data.defaultVariant?.id,
        );
        await _loadRelatedProducts(data);
      case Error<ProductDetails>(:final failure):
        state = ProductDetailsState(
          isLoading: false,
          isRefreshing: false,
          isRelatedLoading: false,
          selectedImageIndex: 0,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  Future<void> refresh() async {
    final existingDetails = state.details;
    state = state.copyWith(
      isRefreshing: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _getProductDetailsUseCase(arg);

    switch (result) {
      case Success<ProductDetails>(:final data):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          details: data,
          selectedImageIndex: 0,
          selectedVariantId: data.defaultVariant?.id,
        );
        await _loadRelatedProducts(data);
      case Error<ProductDetails>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          details: existingDetails,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  void selectImage(int index) {
    state = state.copyWith(selectedImageIndex: index);
  }

  void selectVariant(int? variantId) {
    state = state.copyWith(selectedVariantId: variantId);
  }

  Future<void> _loadRelatedProducts(ProductDetails details) async {
    final categoryId = details.product.category?.id;
    if (categoryId == null) {
      state = state.copyWith(
        isRelatedLoading: false,
        relatedProducts: const <Product>[],
      );
      return;
    }

    state = state.copyWith(
      isRelatedLoading: true,
      clearRelated: true,
    );

    final result = await _getRelatedProductsUseCase(
      productId: details.product.id,
      categoryId: categoryId,
    );

    switch (result) {
      case Success<List<Product>>(:final data):
        state = state.copyWith(
          isRelatedLoading: false,
          relatedProducts: data,
        );
      case Error<List<Product>>():
        state = state.copyWith(
          isRelatedLoading: false,
          relatedProducts: const <Product>[],
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      NetworkFailure() => 'تعذر تحميل تفاصيل المنتج. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() => 'تعذر إكمال الطلب الحالي. حاول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذا المنتج.',
      CacheFailure() => 'حدث خطأ أثناء قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل تفاصيل المنتج.'
          : failure.message,
    };
  }
}
