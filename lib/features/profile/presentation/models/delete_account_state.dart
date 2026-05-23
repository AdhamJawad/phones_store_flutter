import '../../../../core/errors/failure.dart';

class DeleteAccountState {
  const DeleteAccountState({
    required this.isSubmitting,
    required this.isDeleted,
    this.failure,
    this.errorMessage,
  });

  const DeleteAccountState.initial()
      : isSubmitting = false,
        isDeleted = false,
        failure = null,
        errorMessage = null;

  final bool isSubmitting;
  final bool isDeleted;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  DeleteAccountState copyWith({
    bool? isSubmitting,
    bool? isDeleted,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return DeleteAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleted: isDeleted ?? this.isDeleted,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
