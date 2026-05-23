import '../../../../core/errors/failure.dart';
import '../../domain/entities/profile_user.dart';

class ProfileState {
  const ProfileState({
    required this.isLoading,
    required this.isRefreshing,
    this.profile,
    this.failure,
    this.errorMessage,
  });

  const ProfileState.initial()
      : isLoading = true,
        isRefreshing = false,
        profile = null,
        failure = null,
        errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final ProfileUser? profile;
  final Failure? failure;
  final String? errorMessage;

  bool get hasData => profile != null;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  ProfileState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    ProfileUser? profile,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      profile: profile ?? this.profile,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
