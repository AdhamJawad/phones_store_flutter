import 'package:flutter/material.dart';

import '../../../../presentation/theme/app_spacing.dart';

SliverGridDelegate buildProductCardGridDelegate(
  BuildContext context, {
  int? crossAxisCount,
}) {
  final mediaQuery = MediaQuery.of(context);
  final width = mediaQuery.size.width;
  final textScale = mediaQuery.textScaler.scale(1).clamp(1.0, 1.35);

  final columns = crossAxisCount ?? _resolveCrossAxisCount(width);
  const horizontalPadding = AppSpacing.page * 2;
  const crossAxisSpacing = 14.0;
  const mainAxisSpacing = 14.0;

  final availableWidth =
      width - horizontalPadding - (crossAxisSpacing * (columns - 1));
  final itemWidth = availableWidth / columns;
  final imageHeight = itemWidth / 1.08;
  final contentHeight = 118.0 + ((textScale - 1.0) * 56.0);
  final mainAxisExtent = imageHeight + contentHeight;

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisSpacing: mainAxisSpacing,
    mainAxisExtent: mainAxisExtent,
  );
}

int _resolveCrossAxisCount(double width) {
  if (width >= 1200) {
    return 4;
  }
  if (width >= 840) {
    return 3;
  }
  return 2;
}
