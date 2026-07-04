import '../../../../core/errors/failure.dart';
import '../../domain/entities/ai_advisor_result.dart';

class AiAdvisorState {
  const AiAdvisorState({
    required this.query,
    required this.isSubmitting,
    this.result,
    this.failure,
    this.errorMessage,
  });

  const AiAdvisorState.initial()
    : query = '',
      isSubmitting = false,
      result = null,
      failure = null,
      errorMessage = null;

  final String query;
  final bool isSubmitting;
  final AiAdvisorResult? result;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  AiAdvisorState copyWith({
    String? query,
    bool? isSubmitting,
    AiAdvisorResult? result,
    Failure? failure,
    String? errorMessage,
    bool clearResult = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return AiAdvisorState(
      query: query ?? this.query,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: clearResult ? null : result ?? this.result,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
