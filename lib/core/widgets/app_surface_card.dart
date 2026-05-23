import 'package:flutter/material.dart';

import '../../presentation/theme/app_radii.dart';
import '../../presentation/theme/app_shadows.dart';
import '../../presentation/theme/app_spacing.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    super.key,
    this.padding = AppSpacing.cardPadding,
    this.borderRadius = AppRadii.card,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = color ?? theme.colorScheme.surface;

    final content = Padding(
      padding: padding,
      child: child,
    );

    return Material(
      color: background,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: borderRadius,
          boxShadow: AppShadows.card(Colors.black),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: content,
              ),
      ),
    );
  }
}
