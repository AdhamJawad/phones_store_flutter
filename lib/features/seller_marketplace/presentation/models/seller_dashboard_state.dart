import '../../../../core/errors/failure.dart';
import '../../domain/entities/seller_dashboard.dart';

class SellerDashboardState {
  const SellerDashboardState({
    required this.isLoading,
    required this.isRefreshing,
    this.dashboard,
    this.failure,
    this.errorMessage,
  });

  const SellerDashboardState.initial()
      : isLoading = true,
        isRefreshing = false,
        dashboard = null,
        failure = null,
        errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final SellerDashboard? dashboard;
  final Failure? failure;
  final String? errorMessage;

  bool get hasData => dashboard != null;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  SellerDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    SellerDashboard? dashboard,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return SellerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      dashboard: dashboard ?? this.dashboard,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
