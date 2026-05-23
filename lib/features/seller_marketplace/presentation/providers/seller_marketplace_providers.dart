import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/unit.dart';
import '../../../products/domain/entities/product.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../data/datasources/seller_marketplace_remote_data_source.dart';
import '../../data/repositories/seller_marketplace_repository_impl.dart';
import '../../domain/entities/create_listing_input.dart';
import '../../domain/entities/seller_dashboard.dart';
import '../../domain/entities/seller_listings_page.dart';
import '../../domain/entities/update_listing_input.dart';
import '../../domain/repositories/seller_marketplace_repository.dart';
import '../../domain/usecases/create_listing_use_case.dart';
import '../../domain/usecases/delete_listing_use_case.dart';
import '../../domain/usecases/get_seller_dashboard_use_case.dart';
import '../../domain/usecases/get_seller_listings_use_case.dart';
import '../../domain/usecases/update_listing_use_case.dart';
import '../models/listing_form_state.dart';
import '../models/seller_dashboard_state.dart';
import '../models/seller_listings_state.dart';

final sellerImagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final sellerMarketplaceRemoteDataSourceProvider =
    Provider<SellerMarketplaceRemoteDataSource>((ref) {
  return SellerMarketplaceRemoteDataSource(ref.watch(dioProvider));
});

final sellerMarketplaceRepositoryProvider =
    Provider<SellerMarketplaceRepository>((ref) {
  return SellerMarketplaceRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(sellerMarketplaceRemoteDataSourceProvider),
  );
});

final getSellerDashboardUseCaseProvider = Provider<GetSellerDashboardUseCase>((ref) {
  return GetSellerDashboardUseCase(ref.watch(sellerMarketplaceRepositoryProvider));
});

final getSellerListingsUseCaseProvider = Provider<GetSellerListingsUseCase>((ref) {
  return GetSellerListingsUseCase(ref.watch(sellerMarketplaceRepositoryProvider));
});

final createListingUseCaseProvider = Provider<CreateListingUseCase>((ref) {
  return CreateListingUseCase(ref.watch(sellerMarketplaceRepositoryProvider));
});

final updateListingUseCaseProvider = Provider<UpdateListingUseCase>((ref) {
  return UpdateListingUseCase(ref.watch(sellerMarketplaceRepositoryProvider));
});

final deleteListingUseCaseProvider = Provider<DeleteListingUseCase>((ref) {
  return DeleteListingUseCase(ref.watch(sellerMarketplaceRepositoryProvider));
});

final sellerDashboardControllerProvider =
    NotifierProvider<SellerDashboardController, SellerDashboardState>(
  SellerDashboardController.new,
);

final sellerListingsControllerProvider =
    NotifierProvider<SellerListingsController, SellerListingsState>(
  SellerListingsController.new,
);

final listingFormControllerProvider =
    NotifierProvider.autoDispose<ListingFormController, ListingFormState>(
  ListingFormController.new,
);

class SellerDashboardController extends Notifier<SellerDashboardState> {
  GetSellerDashboardUseCase get _getSellerDashboardUseCase =>
      ref.read(getSellerDashboardUseCaseProvider);

  @override
  SellerDashboardState build() {
    Future.microtask(load);
    return const SellerDashboardState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getSellerDashboardUseCase();
    switch (result) {
      case Success<SellerDashboard>(:final data):
        state = SellerDashboardState(
          isLoading: false,
          isRefreshing: false,
          dashboard: data,
        );
      case Error<SellerDashboard>(:final failure):
        state = SellerDashboardState(
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
    final result = await _getSellerDashboardUseCase();
    switch (result) {
      case Success<SellerDashboard>(:final data):
        state = SellerDashboardState(
          isLoading: false,
          isRefreshing: false,
          dashboard: data,
        );
      case Error<SellerDashboard>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }
}

class SellerListingsController extends Notifier<SellerListingsState> {
  GetSellerListingsUseCase get _getSellerListingsUseCase =>
      ref.read(getSellerListingsUseCaseProvider);
  DeleteListingUseCase get _deleteListingUseCase =>
      ref.read(deleteListingUseCaseProvider);

  @override
  SellerListingsState build() {
    Future.microtask(load);
    return const SellerListingsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getSellerListingsUseCase();
    _handleResult(result, replace: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getSellerListingsUseCase();
    _handleResult(result, replace: true);
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
    final result = await _getSellerListingsUseCase(page: nextPage);
    _handleResult(result, replace: false);
  }

  Future<Result<Unit>> deleteListing(int productId) async {
    if (state.deletingIds.contains(productId)) {
      return const Success(Unit.value);
    }
    state = state.copyWith(
      deletingIds: {...state.deletingIds, productId},
      clearError: true,
      clearFailure: true,
    );
    final result = await _deleteListingUseCase(productId);
    final deletingIds = {...state.deletingIds}..remove(productId);
    switch (result) {
      case Success<Unit>():
        state = state.copyWith(
          deletingIds: deletingIds,
          items: state.items.where((item) => item.id != productId).toList(growable: false),
        );
        ref.invalidate(sellerDashboardControllerProvider);
      case Error<Unit>(:final failure):
        state = state.copyWith(
          deletingIds: deletingIds,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
    return result;
  }

  void upsertListing(Product product) {
    final existingIndex = state.items.indexWhere((item) => item.id == product.id);
    final items = [...state.items];
    if (existingIndex == -1) {
      items.insert(0, product);
    } else {
      items[existingIndex] = product;
    }
    state = state.copyWith(items: items);
    ref.invalidate(sellerDashboardControllerProvider);
  }

  void _handleResult(
    Result<SellerListingsPage> result, {
    required bool replace,
  }) {
    switch (result) {
      case Success<SellerListingsPage>(:final data):
        state = SellerListingsState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          deletingIds: state.deletingIds,
          meta: data.meta,
        );
      case Error<SellerListingsPage>(:final failure):
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

class ListingFormController extends AutoDisposeNotifier<ListingFormState> {
  CreateListingUseCase get _createListingUseCase => ref.read(createListingUseCaseProvider);
  UpdateListingUseCase get _updateListingUseCase => ref.read(updateListingUseCaseProvider);
  ImagePicker get _imagePicker => ref.read(sellerImagePickerProvider);

  @override
  ListingFormState build() {
    return const ListingFormState.initial();
  }

  void seedForCreate() {
    state = const ListingFormState.initial();
  }

  void seedForEdit(Product product) {
    state = ListingFormState(
      existingImages: product.images,
      deletedImageIds: const <int>{},
      newImagePaths: const <String>[],
      isSubmitting: false,
      isPickingImages: false,
    );
  }

  Future<void> pickImages() async {
    if (state.isPickingImages) {
      return;
    }
    state = state.copyWith(
      isPickingImages: true,
      clearError: true,
      clearFailure: true,
    );
    try {
      final files = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) {
        state = state.copyWith(isPickingImages: false);
        return;
      }

      final remainingSlots = 5 - state.totalImagesCount;
      if (remainingSlots <= 0) {
        state = state.copyWith(
          isPickingImages: false,
          errorMessage: 'seller.listings_images_limit'.tr(),
        );
        return;
      }

      final paths = files.take(remainingSlots).map((file) => file.path).toList(growable: false);
      state = state.copyWith(
        isPickingImages: false,
        newImagePaths: [...state.newImagePaths, ...paths],
      );
    } catch (_) {
      state = state.copyWith(
        isPickingImages: false,
        errorMessage: 'seller.image_pick_error'.tr(),
      );
    }
  }

  void removeNewImage(String path) {
    state = state.copyWith(
      newImagePaths: state.newImagePaths.where((item) => item != path).toList(growable: false),
      clearError: true,
      clearFailure: true,
    );
  }

  void markExistingImageDeleted(int imageId) {
    state = state.copyWith(
      deletedImageIds: {...state.deletedImageIds, imageId},
      clearError: true,
      clearFailure: true,
    );
  }

  Future<Result<Product>> submitCreate(CreateListingInput input) async {
    if (input.imagePaths.isEmpty) {
      return Error<Product>(
        ValidationFailure(message: 'seller.create_image_required'.tr()),
      );
    }
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _createListingUseCase(input);
    switch (result) {
      case Success<Product>():
        state = state.copyWith(isSubmitting: false);
        ref.invalidate(sellerDashboardControllerProvider);
        ref.invalidate(walletSummaryProvider);
      case Error<Product>(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
    return result;
  }

  Future<Result<Product>> submitUpdate({
    required int productId,
    required UpdateListingInput input,
  }) async {
    final totalCount = state.visibleExistingImages.length + input.newImagePaths.length;
    if (totalCount > 5) {
      return Error<Product>(
        ValidationFailure(message: 'seller.listings_images_limit'.tr()),
      );
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _updateListingUseCase(productId, input);
    switch (result) {
      case Success<Product>(:final data):
        state = state.copyWith(
          isSubmitting: false,
          existingImages: data.images,
          deletedImageIds: const <int>{},
          newImagePaths: const <String>[],
        );
        ref.invalidate(sellerDashboardControllerProvider);
      case Error<Product>(:final failure):
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
    UnauthorizedFailure() => 'يجب تسجيل الدخول للوصول إلى إعلاناتك.',
    ForbiddenFailure() => 'ليس لديك صلاحية لتنفيذ هذا الإجراء.',
    NetworkFailure() => 'تعذر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مرة أخرى.',
    CacheFailure() => 'تعذر قراءة البيانات المحلية.',
    ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
    UnknownFailure() => failure.message.isEmpty
        ? 'حدث خطأ غير متوقع أثناء تنفيذ الطلب.'
        : failure.message,
  };
}
