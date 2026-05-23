import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

final appLifecycleControllerProvider = Provider<AppLifecycleController>((ref) {
  final controller = AppLifecycleController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class AppLifecycleController with WidgetsBindingObserver {
  AppLifecycleController(this._ref);

  final Ref _ref;
  bool _started = false;
  bool _refreshInFlight = false;
  DateTime? _lastRefreshAt;

  void start() {
    if (_started) {
      return;
    }

    _started = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAuthIfNeeded());
    }
  }

  Future<void> _refreshAuthIfNeeded() async {
    if (_refreshInFlight) {
      return;
    }

    final authState = _ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      return;
    }

    final now = DateTime.now();
    final lastRefreshAt = _lastRefreshAt;
    if (lastRefreshAt != null &&
        now.difference(lastRefreshAt) < const Duration(minutes: 3)) {
      return;
    }

    _refreshInFlight = true;
    _lastRefreshAt = now;

    try {
      await _ref.read(authControllerProvider.notifier).refreshCurrentUser();
    } finally {
      _refreshInFlight = false;
    }
  }
}
