import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/unit.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_user.dart';
import '../../domain/entities/update_profile_input.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/delete_account_use_case.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../models/delete_account_state.dart';
import '../models/profile_state.dart';
import '../models/update_profile_state.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.watch(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(profileRepositoryProvider));
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

final updateProfileControllerProvider = NotifierProvider.autoDispose<
    UpdateProfileController, UpdateProfileState>(UpdateProfileController.new);

final deleteAccountControllerProvider = NotifierProvider.autoDispose<
    DeleteAccountController, DeleteAccountState>(DeleteAccountController.new);

class ProfileController extends Notifier<ProfileState> {
  GetProfileUseCase get _getProfileUseCase => ref.read(getProfileUseCaseProvider);

  @override
  ProfileState build() {
    Future.microtask(load);
    return const ProfileState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getProfileUseCase();
    switch (result) {
      case Success<ProfileUser>(:final data):
        state = ProfileState(
          isLoading: false,
          isRefreshing: false,
          profile: data,
        );
      case Error<ProfileUser>(:final failure):
        state = ProfileState(
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
    final result = await _getProfileUseCase();
    switch (result) {
      case Success<ProfileUser>(:final data):
        state = ProfileState(
          isLoading: false,
          isRefreshing: false,
          profile: data,
        );
      case Error<ProfileUser>(:final failure):
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  void setProfile(ProfileUser profile) {
    state = ProfileState(
      isLoading: false,
      isRefreshing: false,
      profile: profile,
    );
  }

  String _mapFailure(Failure failure) {
    return _profileFailureMessage(failure, 'profile.load_error_fallback');
  }
}

class UpdateProfileController extends AutoDisposeNotifier<UpdateProfileState> {
  UpdateProfileUseCase get _updateProfileUseCase =>
      ref.read(updateProfileUseCaseProvider);

  @override
  UpdateProfileState build() {
    return const UpdateProfileState.initial();
  }

  Future<Result<ProfileUser>> submit(UpdateProfileInput input) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFailure: true,
      clearUpdatedProfile: true,
    );

    final result = await _updateProfileUseCase(input);
    switch (result) {
      case Success<ProfileUser>(:final data):
        state = state.copyWith(
          isSubmitting: false,
          updatedProfile: data,
        );
        ref.read(profileControllerProvider.notifier).setProfile(data);
        ref.read(authControllerProvider.notifier).replaceSessionUser(data.toAuthUser());
        ref.invalidate(walletSummaryProvider);
      case Error<ProfileUser>(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: _profileFailureMessage(
            failure,
            'profile.update_error_fallback',
          ),
        );
    }

    return result;
  }
}

class DeleteAccountController extends AutoDisposeNotifier<DeleteAccountState> {
  DeleteAccountUseCase get _deleteAccountUseCase =>
      ref.read(deleteAccountUseCaseProvider);

  @override
  DeleteAccountState build() {
    return const DeleteAccountState.initial();
  }

  Future<Result<Unit>> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      isDeleted: false,
      clearError: true,
      clearFailure: true,
    );

    final result = await _deleteAccountUseCase();
    switch (result) {
      case Success<Unit>():
        state = state.copyWith(
          isSubmitting: false,
          isDeleted: true,
        );
        ref.read(authControllerProvider.notifier).forceUnauthenticated();
        ref.invalidate(walletSummaryProvider);
      case Error<Unit>(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: _profileFailureMessage(
            failure,
            'profile.delete_error_fallback',
          ),
        );
    }

    return result;
  }
}

String _profileFailureMessage(Failure failure, String fallbackKey) {
  return switch (failure) {
    ValidationFailure() => failure.message,
    UnauthorizedFailure() => 'يجب تسجيل الدخول للوصول إلى هذه الصفحة.',
    ForbiddenFailure() => 'ليس لديك صلاحية لتنفيذ هذا الإجراء.',
    NetworkFailure() =>
      'تعذر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مرة أخرى.',
    CacheFailure() => 'تعذر قراءة البيانات المحلية.',
    ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
    UnknownFailure() => failure.message.isEmpty
        ? fallbackKey
        : failure.message,
  };
}
