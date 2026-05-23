import '../../../../core/errors/failure.dart';
import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/app_notification_item.dart';

class NotificationsState {
  const NotificationsState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.isMarkingAllAsRead,
    required this.busyIds,
    this.meta,
    this.failure,
    this.errorMessage,
  });

  const NotificationsState.initial()
      : items = const <AppNotificationItem>[],
        isLoading = true,
        isRefreshing = false,
        isLoadingMore = false,
        isMarkingAllAsRead = false,
        busyIds = const <String>{},
        meta = null,
        failure = null,
        errorMessage = null;

  final List<AppNotificationItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isMarkingAllAsRead;
  final Set<String> busyIds;
  final PaginatedResponseMeta? meta;
  final Failure? failure;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get canLoadMore => meta?.hasMorePages ?? false;
  int get unreadCount => items.where((item) => !item.isRead).length;

  NotificationsState copyWith({
    List<AppNotificationItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isMarkingAllAsRead,
    Set<String>? busyIds,
    PaginatedResponseMeta? meta,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingAllAsRead: isMarkingAllAsRead ?? this.isMarkingAllAsRead,
      busyIds: busyIds ?? this.busyIds,
      meta: meta ?? this.meta,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
