import 'package:flutter/material.dart';

enum EnvironmentFlavor {
  development,
  staging,
  production,
}

final class AppEnvironment {
  AppEnvironment._();

  static bool _initialized = false;

  static late final EnvironmentFlavor flavor;
  static late final String appName;
  static late final String baseUrl;
  static late final bool enableDioLogs;
  static late final bool requireSecureTransport;
  static late final bool isReleaseLike;

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const fallbackLocale = Locale('en');
  static const defaultLocale = Locale('ar');

  static void ensureInitialized() {
    if (_initialized) {
      return;
    }

    const flavorName = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'development',
    );

    flavor = switch (flavorName) {
      'production' => EnvironmentFlavor.production,
      'staging' => EnvironmentFlavor.staging,
      _ => EnvironmentFlavor.development,
    };

    appName = const String.fromEnvironment(
      'APP_NAME',
      defaultValue: 'PhoneMarket',
    );

    final configuredBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api/v1',
    );
    baseUrl = configuredBaseUrl.trim().replaceAll(RegExp(r'/$'), '');

    enableDioLogs = const bool.fromEnvironment(
      'ENABLE_DIO_LOGS',
      defaultValue: true,
    );

    isReleaseLike =
        flavor == EnvironmentFlavor.staging || flavor == EnvironmentFlavor.production;
    requireSecureTransport = const bool.fromEnvironment(
      'REQUIRE_SECURE_TRANSPORT',
      defaultValue: false,
    );

    if (baseUrl.isEmpty) {
      throw StateError('API_BASE_URL must not be empty.');
    }

    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL is invalid: $baseUrl');
    }

    if (requireSecureTransport && uri.scheme != 'https') {
      throw StateError(
        'Production/staging builds must use HTTPS API_BASE_URL. Received: $baseUrl',
      );
    }

    _initialized = true;
  }
}
