import '../../../../core/errors/failure.dart';
import '../../domain/entities/profile_user.dart';

class UpdateProfileState {
  const UpdateProfileState({
    required this.isSubmitting,
    this.updatedProfile,
    this.failure,
    this.errorMessage,
  });

  const UpdateProfileState.initial()
      : isSubmitting = false,
        updatedProfile = null,
        failure = null,
        errorMessage = null;

  final bool isSubmitting;
  final ProfileUser? updatedProfile;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  UpdateProfileState copyWith({
    bool? isSubmitting,
    ProfileUser? updatedProfile,
    Failure? failure,
    String? errorMessage,
    bool clearUpdatedProfile = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return UpdateProfileState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      updatedProfile: clearUpdatedProfile
          ? null
          : updatedProfile ?? this.updatedProfile,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
