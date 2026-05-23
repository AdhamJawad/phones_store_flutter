import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/app/app_error_reporter.dart';
import 'core/app/app_startup.dart';

Future<void> main() async {
  await _run();
}

Future<void> _run() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      AppErrorReporter.report(
        details.exception,
        details.stack ?? StackTrace.current,
        context: 'FlutterError',
      ),
    );
  };
  ErrorWidget.builder = (details) {
    return const Material(
      color: Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'A rendering error occurred.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      AppErrorReporter.report(error, stack, context: 'PlatformDispatcher'),
    );
    return true;
  };

  await runZonedGuarded(() async {
    final app = await bootstrapApplication();
    runApp(app);
  }, (error, stackTrace) async {
    await AppErrorReporter.report(
      error,
      stackTrace,
      context: 'runZonedGuarded',
    );
  });
}
