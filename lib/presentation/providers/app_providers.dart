import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../routing/app_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRouterNotifier = ref.watch(authRouterNotifierProvider);
  return AppRouter.create(authRouterNotifier);
});
