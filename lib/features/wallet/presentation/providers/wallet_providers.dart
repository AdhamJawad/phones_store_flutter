import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/create_recharge_request_input.dart';
import '../../domain/entities/recharge_method.dart';
import '../../domain/entities/recharge_request.dart';
import '../../domain/entities/recharge_request_page.dart';
import '../../domain/entities/wallet_dashboard.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/entities/wallet_transaction_page.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/create_recharge_request_use_case.dart';
import '../../domain/usecases/get_recharge_requests_use_case.dart';
import '../../domain/usecases/get_wallet_dashboard_use_case.dart';
import '../../domain/usecases/get_wallet_summary_use_case.dart';
import '../../domain/usecases/get_wallet_transactions_use_case.dart';
import '../models/create_recharge_request_state.dart';
import '../models/recharge_requests_state.dart';
import '../models/wallet_dashboard_state.dart';
import '../models/wallet_transactions_state.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  return WalletRemoteDataSource(ref.watch(dioProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(walletRemoteDataSourceProvider),
  );
});

final getWalletSummaryUseCaseProvider = Provider<GetWalletSummaryUseCase>((ref) {
  return GetWalletSummaryUseCase(ref.watch(walletRepositoryProvider));
});

final getWalletTransactionsUseCaseProvider =
    Provider<GetWalletTransactionsUseCase>((ref) {
  return GetWalletTransactionsUseCase(ref.watch(walletRepositoryProvider));
});

final getRechargeRequestsUseCaseProvider =
    Provider<GetRechargeRequestsUseCase>((ref) {
  return GetRechargeRequestsUseCase(ref.watch(walletRepositoryProvider));
});

final createRechargeRequestUseCaseProvider =
    Provider<CreateRechargeRequestUseCase>((ref) {
  return CreateRechargeRequestUseCase(ref.watch(walletRepositoryProvider));
});

final getWalletDashboardUseCaseProvider =
    Provider<GetWalletDashboardUseCase>((ref) {
  return GetWalletDashboardUseCase(ref.watch(walletRepositoryProvider));
});

final walletDashboardControllerProvider =
    NotifierProvider<WalletDashboardController, WalletDashboardState>(
  WalletDashboardController.new,
);

final walletTransactionsControllerProvider =
    NotifierProvider<WalletTransactionsController, WalletTransactionsState>(
  WalletTransactionsController.new,
);

final rechargeRequestsControllerProvider =
    NotifierProvider<RechargeRequestsController, RechargeRequestsState>(
  RechargeRequestsController.new,
);

final createRechargeRequestControllerProvider = NotifierProvider.autoDispose<
    CreateRechargeRequestController, CreateRechargeRequestState>(
  CreateRechargeRequestController.new,
);

final walletSummaryProvider = FutureProvider<WalletSummary?>((ref) async {
  final result = await ref.watch(getWalletSummaryUseCaseProvider)();
  return switch (result) {
    Success<WalletSummary>(:final data) => data,
    Error<WalletSummary>() => null,
  };
});

class WalletDashboardController extends Notifier<WalletDashboardState> {
  GetWalletDashboardUseCase get _getWalletDashboardUseCase =>
      ref.read(getWalletDashboardUseCaseProvider);

  @override
  WalletDashboardState build() {
    Future.microtask(load);
    return const WalletDashboardState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getWalletDashboardUseCase();
    switch (result) {
      case Success<WalletDashboard>(:final data):
        state = WalletDashboardState(
          isLoading: false,
          isRefreshing: false,
          dashboard: data,
        );
      case Error<WalletDashboard>(:final failure):
        state = WalletDashboardState(
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
    final result = await _getWalletDashboardUseCase();
    switch (result) {
      case Success<WalletDashboard>(:final data):
        state = WalletDashboardState(
          isLoading: false,
          isRefreshing: false,
          dashboard: data,
        );
      case Error<WalletDashboard>(:final failure):
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
      UnauthorizedFailure() => 'يجب تسجيل الدخول للوصول إلى المحفظة.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى بيانات المحفظة.',
      NetworkFailure() => 'تعذر تحميل المحفظة. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل المحفظة.'
          : failure.message,
    };
  }
}

class WalletTransactionsController extends Notifier<WalletTransactionsState> {
  GetWalletTransactionsUseCase get _getWalletTransactionsUseCase =>
      ref.read(getWalletTransactionsUseCaseProvider);

  @override
  WalletTransactionsState build() {
    Future.microtask(load);
    return const WalletTransactionsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getWalletTransactionsUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getWalletTransactionsUseCase();
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
    final result = await _getWalletTransactionsUseCase(page: nextPage);
    _handlePageResult(result, replace: false);
  }

  void _handlePageResult(
    Result<WalletTransactionPage> result, {
    required bool replace,
  }) {
    switch (result) {
      case Success<WalletTransactionPage>(:final data):
        state = WalletTransactionsState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          meta: data.meta,
        );
      case Error<WalletTransactionPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'يجب تسجيل الدخول لعرض معاملات المحفظة.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذه المعاملات.',
      NetworkFailure() =>
        'تعذر تحميل المعاملات. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل المعاملات.'
          : failure.message,
    };
  }
}

class RechargeRequestsController extends Notifier<RechargeRequestsState> {
  GetRechargeRequestsUseCase get _getRechargeRequestsUseCase =>
      ref.read(getRechargeRequestsUseCaseProvider);

  @override
  RechargeRequestsState build() {
    Future.microtask(load);
    return const RechargeRequestsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getRechargeRequestsUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getRechargeRequestsUseCase();
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
    final result = await _getRechargeRequestsUseCase(page: nextPage);
    _handlePageResult(result, replace: false);
  }

  void prependCreatedRequest(RechargeRequest request) {
    state = state.copyWith(items: [request, ...state.items]);
    ref.invalidate(walletDashboardControllerProvider);
    ref.invalidate(walletSummaryProvider);
  }

  void _handlePageResult(
    Result<RechargeRequestPage> result, {
    required bool replace,
  }) {
    switch (result) {
      case Success<RechargeRequestPage>(:final data):
        state = RechargeRequestsState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          meta: data.meta,
        );
      case Error<RechargeRequestPage>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      UnauthorizedFailure() => 'يجب تسجيل الدخول لعرض طلبات الشحن.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى طلبات الشحن.',
      NetworkFailure() =>
        'تعذر تحميل طلبات الشحن. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل طلبات الشحن.'
          : failure.message,
    };
  }
}

class CreateRechargeRequestController
    extends AutoDisposeNotifier<CreateRechargeRequestState> {
  CreateRechargeRequestUseCase get _createRechargeRequestUseCase =>
      ref.read(createRechargeRequestUseCaseProvider);

  ImagePicker get _imagePicker => ref.read(imagePickerProvider);

  @override
  CreateRechargeRequestState build() {
    return CreateRechargeRequestState.initial();
  }

  void setMethod(RechargeMethod method) {
    state = state.copyWith(
      method: method,
      clearError: true,
      clearFailure: true,
    );
  }

  Future<void> pickProofImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    state = state.copyWith(
      proofFilePath: file.path,
      clearError: true,
      clearFailure: true,
    );
  }

  void clearProofImage() {
    state = state.copyWith(clearProof: true);
  }

  Future<Result<RechargeRequest>> submit({
    required double amount,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFailure: true,
      clearCreatedRequest: true,
    );

    final result = await _createRechargeRequestUseCase(
      CreateRechargeRequestInput(
        amount: amount,
        method: state.method.apiValue,
        proofFilePath: state.proofFilePath,
      ),
    );

    switch (result) {
      case Success<RechargeRequest>(:final data):
        state = state.copyWith(
          isSubmitting: false,
          createdRequest: data,
        );
      case Error<RechargeRequest>(:final failure):
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
      UnauthorizedFailure() => 'يجب تسجيل الدخول لإرسال طلب شحن.',
      ForbiddenFailure() => 'ليس لديك صلاحية لإرسال هذا الطلب.',
      NetworkFailure() =>
        'تعذر إرسال طلب الشحن. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء إرسال طلب الشحن.'
          : failure.message,
    };
  }
}
