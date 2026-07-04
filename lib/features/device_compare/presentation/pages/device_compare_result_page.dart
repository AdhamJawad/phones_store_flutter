import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../device_catalog/domain/entities/device.dart';
import '../../domain/entities/device_comparison.dart';
import '../providers/device_compare_providers.dart';

class DeviceCompareResultPage extends ConsumerWidget {
  const DeviceCompareResultPage({required this.deviceIds, super.key});

  final List<int> deviceIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestKey = deviceIds.join(',');
    final state = ref.watch(deviceCompareResultControllerProvider(requestKey));
    final controller = ref.read(
      deviceCompareResultControllerProvider(requestKey).notifier,
    );

    if (state.isLoading && state.comparison == null) {
      return const _CompareResultLoadingPage();
    }

    if (state.hasError && state.comparison == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text('compare.result_title'.tr()),
        ),
        body: AppErrorState(
          title: 'compare.results_error_title'.tr(),
          message: state.errorMessage!,
          actionLabel: 'common.retry'.tr(),
          onRetry: controller.load,
        ),
      );
    }

    final comparison = state.comparison;
    if (comparison == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text('compare.result_title'.tr()),
        ),
        body: AppEmptyState(
          title: 'compare.results_empty_title'.tr(),
          message: 'compare.results_empty_message'.tr(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('compare.result_title'.tr()),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.page,
            AppSpacing.page,
            28,
          ),
          children: [
            Text(
              'compare.result_title'.tr(),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'compare.result_subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var index = 0;
                    index < comparison.devices.length;
                    index++
                  ) ...[
                    Expanded(
                      child: _CompareHeaderCard(
                        device: comparison.devices[index],
                      ),
                    ),
                    if (index < comparison.devices.length - 1)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ComparisonTable(comparison: comparison),
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.comparison});

  final DeviceComparison comparison;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        children: comparison.rows
            .map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.generate(2, (index) {
                        final value = index < row.values.length
                            ? row.values[index]
                            : '-';
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: index == 0 ? 10 : 0,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: row.different
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.08)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.lg,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  value,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _CompareHeaderCard extends StatelessWidget {
  const _CompareHeaderCard({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: AppNetworkImage(
              imageUrl: device.imageUrl,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
            ),
          ),
          SizedBox(
            height: 96,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    device.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareResultLoadingPage extends StatelessWidget {
  const _CompareResultLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('compare.result_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AppSurfaceCard(
              child: AppSkeleton(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(height: 24, width: 180),
                    SizedBox(height: 10),
                    AppSkeletonBox(height: 16, width: double.infinity),
                    SizedBox(height: 24),
                    AppSkeletonBox(height: 180, width: double.infinity),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: AppSurfaceCard(
                child: AppSkeleton(
                  child: Column(
                    children: [
                      AppSkeletonBox(height: 18, width: double.infinity),
                      SizedBox(height: 18),
                      AppSkeletonBox(height: 18, width: double.infinity),
                      SizedBox(height: 18),
                      AppSkeletonBox(height: 18, width: double.infinity),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
