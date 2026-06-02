import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/models/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../features/orders/presentation/providers/orders_providers.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import '../../features/wallet/presentation/providers/wallet_providers.dart';
import '../routing/app_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRouterNotifier = ref.watch(authRouterNotifierProvider);
  return AppRouter.create(authRouterNotifier);
});

final authSessionSyncProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (!_didAuthSessionChange(previous, next)) {
      return;
    }

    ref.invalidate(profileControllerProvider);
    ref.invalidate(walletDashboardControllerProvider);
    ref.invalidate(walletTransactionsControllerProvider);
    ref.invalidate(rechargeRequestsControllerProvider);
    ref.invalidate(walletSummaryProvider);
    ref.invalidate(buyerOrdersControllerProvider);
    ref.invalidate(salesOrdersControllerProvider);
    ref.invalidate(notificationsControllerProvider);
  });
});

bool _didAuthSessionChange(AuthState? previous, AuthState next) {
  final previousSession = previous?.session;
  final nextSession = next.session;

  if (previousSession == null && nextSession == null) {
    return false;
  }

  if (previousSession == null || nextSession == null) {
    return true;
  }

  return previousSession.user.id != nextSession.user.id ||
      previousSession.token != nextSession.token;
}
