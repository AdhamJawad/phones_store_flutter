import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_connectivity_banner.dart';
import 'app_lifecycle_scope.dart';
import '../presentation/providers/app_providers.dart';
import '../presentation/theme/app_branding.dart';
import '../presentation/theme/app_theme.dart';

class PhoneMarketApp extends ConsumerWidget {
  const PhoneMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AppLifecycleScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppBranding.appName,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
        builder: (context, child) {
          return AppConnectivityBanner(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
