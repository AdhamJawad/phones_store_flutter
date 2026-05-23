import 'package:flutter/material.dart';

final class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.06),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> elevated(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.16),
        blurRadius: 30,
        offset: const Offset(0, 16),
      ),
    ];
  }
}
