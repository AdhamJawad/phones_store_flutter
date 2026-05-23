import 'package:flutter/material.dart';

import '../../presentation/theme/app_spacing.dart';

class AppSectionContainer extends StatelessWidget {
  const AppSectionContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.page,
      0,
      AppSpacing.page,
      0,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}
