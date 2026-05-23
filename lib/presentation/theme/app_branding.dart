import 'package:flutter/material.dart';

import 'app_colors.dart';

final class AppBranding {
  AppBranding._();

  static const String appName = 'Phone market';
  static const String androidLauncherPlaceholder = 'ic_launcher';
  static const Color splashBackground = AppColors.background;
  static const Gradient primaryHeroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );
}
