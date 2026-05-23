final class AppConstants {
  AppConstants._();

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 30);
  static const startupTimeout = Duration(seconds: 12);
  static const requestDeduplicationWindow = Duration(seconds: 15);
  static const defaultPageSize = 15;
}
