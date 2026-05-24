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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxWidth / 1.16;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(
                  height: imageHeight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.xl),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AppSkeletonBox(
                          height: 15,
                          width: double.infinity,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.pill),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AppSkeletonBox(
                          height: 15,
                          width: 110,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.pill),
                          ),
                        ),
                        Spacer(),
                        AppSkeletonBox(
                          height: 15,
                          width: 88,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.pill),
                          ),
                        ),
                        Spacer(),
                        AppSkeletonBox(
                          height: 12,
                          width: 120,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.pill),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
