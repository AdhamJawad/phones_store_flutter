import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../config/env.dart';
import '../storage/hive_service.dart';

Future<Widget> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveService.instance.init();
  AppEnvironment.ensureInitialized();

  return ProviderScope(
    child: EasyLocalization(
      supportedLocales: AppEnvironment.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: AppEnvironment.fallbackLocale,
      startLocale: AppEnvironment.defaultLocale,
      child: const PhoneMarketApp(),
    ),
  );
}
