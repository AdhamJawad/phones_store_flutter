import '../../../../core/errors/failure.dart';
import '../../domain/entities/home_feed.dart';

class HomeState {
  const HomeState({
    required this.isLoading,
    required this.isRefreshing,
    this.feed,
    this.failure,
    this.errorMessage,
  });

  const HomeState.initial()
      : isLoading = true,
        isRefreshing = false,
        feed = null,
        failure = null,
        errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final HomeFeed? feed;
  final Failure? failure;
  final String? errorMessage;

  bool get hasData => feed != null;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  HomeState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    HomeFeed? feed,
    Failure? failure,
    String? errorMessage,
    bool clearFeed = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      feed: clearFeed ? null : feed ?? this.feed,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
