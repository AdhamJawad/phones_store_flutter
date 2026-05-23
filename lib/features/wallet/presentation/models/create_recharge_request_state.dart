import '../../../../core/errors/failure.dart';
import '../../domain/entities/recharge_method.dart';
import '../../domain/entities/recharge_request.dart';

class CreateRechargeRequestState {
  const CreateRechargeRequestState({
    required this.method,
    required this.isSubmitting,
    this.proofFilePath,
    this.createdRequest,
    this.failure,
    this.errorMessage,
  });

  factory CreateRechargeRequestState.initial() {
    return const CreateRechargeRequestState(
      method: RechargeMethod.syriatelCash,
      isSubmitting: false,
      proofFilePath: null,
      createdRequest: null,
      failure: null,
      errorMessage: null,
    );
  }

  final RechargeMethod method;
  final bool isSubmitting;
  final String? proofFilePath;
  final RechargeRequest? createdRequest;
  final Failure? failure;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  CreateRechargeRequestState copyWith({
    RechargeMethod? method,
    bool? isSubmitting,
    String? proofFilePath,
    RechargeRequest? createdRequest,
    Failure? failure,
    String? errorMessage,
    bool clearProof = false,
    bool clearCreatedRequest = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return CreateRechargeRequestState(
      method: method ?? this.method,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      proofFilePath: clearProof ? null : proofFilePath ?? this.proofFilePath,
      createdRequest: clearCreatedRequest
          ? null
          : createdRequest ?? this.createdRequest,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
