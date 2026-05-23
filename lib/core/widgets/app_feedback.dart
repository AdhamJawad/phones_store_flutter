import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class AppFeedback {
  AppFeedback._();

  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void success(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  static void error(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
        ),
      );
  }
}
