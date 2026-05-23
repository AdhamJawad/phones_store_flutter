import 'package:flutter/material.dart';

import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSkeletonBox(
              height: 170,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppSkeletonBox(
                    height: 16,
                    width: double.infinity,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.pill),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppSkeletonBox(
                    height: 16,
                    width: 140,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.pill),
                    ),
                  ),
                  SizedBox(height: 14),
                  AppSkeletonBox(
                    height: 12,
                    width: 120,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.pill),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppSkeletonBox(
                    height: 12,
                    width: 90,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.pill),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
