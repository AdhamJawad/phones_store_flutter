import '../../../../core/errors/failure.dart';
import '../../domain/entities/wallet_dashboard.dart';

class WalletDashboardState {
  const WalletDashboardState({
    required this.isLoading,
    required this.isRefreshing,
    this.dashboard,
    this.failure,
    this.errorMessage,
  });

  const WalletDashboardState.initial()
      : isLoading = true,
        isRefreshing = false,
        dashboard = null,
        failure = null,
        errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final WalletDashboard? dashboard;
  final Failure? failure;
  final String? errorMessage;

  bool get hasData => dashboard != null;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  WalletDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    WalletDashboard? dashboard,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return WalletDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      dashboard: dashboard ?? this.dashboard,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
