import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification_item.dart';
import '../../domain/entities/notification_mark_all_result.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';
import '../models/notifications_state.dart';

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(ref.watch(dioProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(notificationsRemoteDataSourceProvider),
  );
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.watch(notificationsRepositoryProvider));
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(ref.watch(notificationsRepositoryProvider));
});

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>((ref) {
  return MarkAllNotificationsReadUseCase(
    ref.watch(notificationsRepositoryProvider),
  );
});

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);

class NotificationsController extends Notifier<NotificationsState> {
  GetNotificationsUseCase get _getNotificationsUseCase =>
      ref.read(getNotificationsUseCaseProvider);
  MarkNotificationReadUseCase get _markNotificationReadUseCase =>
      ref.read(markNotificationReadUseCaseProvider);
  MarkAllNotificationsReadUseCase get _markAllNotificationsReadUseCase =>
      ref.read(markAllNotificationsReadUseCaseProvider);

  @override
  NotificationsState build() {
    Future.microtask(load);
    return const NotificationsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getNotificationsUseCase();
    _handlePageResult(result, replace: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _getNotificationsUseCase();
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
    final result = await _getNotificationsUseCase(page: nextPage);
    _handlePageResult(result, replace: false);
  }

  Future<Result<AppNotificationItem>> markAsRead(String notificationId) async {
    if (state.busyIds.contains(notificationId)) {
      return Error<AppNotificationItem>(
        UnknownFailure(message: 'Notification is already being updated.'),
      );
    }

    state = state.copyWith(
      busyIds: {...state.busyIds, notificationId},
      clearError: true,
      clearFailure: true,
    );

    final result = await _markNotificationReadUseCase(notificationId);
    final nextBusyIds = {...state.busyIds}..remove(notificationId);

    switch (result) {
      case Success<AppNotificationItem>(:final data):
        final items = state.items
            .map((item) => item.id == data.id ? data : item)
            .toList(growable: false);
        state = state.copyWith(
          items: items,
          busyIds: nextBusyIds,
        );
      case Error<AppNotificationItem>(:final failure):
        state = state.copyWith(
          busyIds: nextBusyIds,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }

    return result;
  }

  Future<Result<NotificationMarkAllResult>> markAllAsRead() async {
    if (state.isMarkingAllAsRead || state.unreadCount == 0) {
      return Success(NotificationMarkAllResult(updatedCount: 0));
    }

    state = state.copyWith(
      isMarkingAllAsRead: true,
      clearError: true,
      clearFailure: true,
    );
    final result = await _markAllNotificationsReadUseCase();

    switch (result) {
      case Success<NotificationMarkAllResult>():
        final now = DateTime.now();
        final items = state.items
            .map((item) => item.isRead ? item : item.copyWith(isRead: true, readAt: now))
            .toList(growable: false);
        state = state.copyWith(
          items: items,
          isMarkingAllAsRead: false,
        );
      case Error<NotificationMarkAllResult>(:final failure):
        state = state.copyWith(
          isMarkingAllAsRead: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }

    return result;
  }

  void _handlePageResult(
    Result<NotificationPage> result, {
    required bool replace,
  }) {
    switch (result) {
      case Success<NotificationPage>(:final data):
        state = NotificationsState(
          items: replace ? data.items : [...state.items, ...data.items],
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          isMarkingAllAsRead: false,
          busyIds: state.busyIds,
          meta: data.meta,
        );
      case Error<NotificationPage>(:final failure):
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
      UnauthorizedFailure() =>
        'يجب تسجيل الدخول للوصول إلى الإشعارات.',
      ForbiddenFailure() =>
        'ليس لديك صلاحية للوصول إلى الإشعارات.',
      NetworkFailure() =>
        'تعذر تحميل الإشعارات. تحقق من الاتصال ثم حاول مرة أخرى.',
      CacheFailure() =>
        'تعذر قراءة بعض البيانات المحلية.',
      ServerFailure() =>
        'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() => failure.message.isEmpty
          ? 'حدث خطأ غير متوقع أثناء تحميل الإشعارات.'
          : failure.message,
    };
  }
}
