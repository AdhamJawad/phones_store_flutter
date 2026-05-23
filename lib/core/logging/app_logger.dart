import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

final class AppLogger {
  AppLogger._();

  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'PhoneMarket',
      error: error,
      stackTrace: stackTrace,
      level: 800,
    );
  }

  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'PhoneMarket',
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'PhoneMarket',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void debug(String message) {
    if (!kDebugMode) {
      return;
    }

    developer.log(
      message,
      name: 'PhoneMarket',
      level: 700,
    );
  }
}
