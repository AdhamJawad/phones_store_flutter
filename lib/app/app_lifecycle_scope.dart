import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app/app_lifecycle_controller.dart';

class AppLifecycleScope extends ConsumerStatefulWidget {
  const AppLifecycleScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AppLifecycleScope> createState() => _AppLifecycleScopeState();
}

class _AppLifecycleScopeState extends ConsumerState<AppLifecycleScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLifecycleControllerProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
