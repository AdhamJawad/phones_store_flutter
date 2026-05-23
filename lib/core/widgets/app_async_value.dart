import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_state.dart';

class AppAsyncValue<T> extends StatelessWidget {
  const AppAsyncValue({
    required this.value,
    required this.data,
    super.key,
    this.loading,
    this.errorTitle,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final String? errorTitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ??
          const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
      error: (error, stackTrace) => AppErrorState(
        title: errorTitle ?? 'Something went wrong',
        message: error.toString(),
        actionLabel: onRetry == null ? null : 'Retry',
        onRetry: onRetry,
      ),
    );
  }
}
