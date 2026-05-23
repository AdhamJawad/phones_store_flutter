import '../logging/app_logger.dart';

typedef ErrorHook = Future<void> Function(
  Object error,
  StackTrace stackTrace,
  String context,
);

final class AppErrorReporter {
  AppErrorReporter._();

  static ErrorHook? _hook;

  static void setHook(ErrorHook? hook) {
    _hook = hook;
  }

  static Future<void> report(
    Object error,
    StackTrace stackTrace, {
    required String context,
  }) async {
    AppLogger.error(
      'Unhandled application error [$context]',
      error: error,
      stackTrace: stackTrace,
    );

    final hook = _hook;
    if (hook != null) {
      await hook(error, stackTrace, context);
    }
  }
}
