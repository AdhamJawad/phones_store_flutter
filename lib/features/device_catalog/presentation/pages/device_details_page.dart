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
import '../../domain/entities/device.dart';
import '../providers/device_catalog_providers.dart';
import '../widgets/device_spec_row.dart';

class DeviceDetailsPage extends ConsumerWidget {
  const DeviceDetailsPage({required this.deviceId, super.key});

  final int deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceDetailsControllerProvider(deviceId));
    final controller = ref.read(
      deviceDetailsControllerProvider(deviceId).notifier,
    );

    if (state.isLoading && state.device == null) {
      return const _DeviceDetailsLoadingPage();
    }

    if (state.hasError && state.device == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: AppErrorState(
          title: 'devices.details_error_title'.tr(),
          message: state.errorMessage!,
          actionLabel: 'common.retry'.tr(),
          onRetry: controller.load,
        ),
      );
    }

    final device = state.device;
    if (device == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: AppEmptyState(
          title: 'devices.details_empty_title'.tr(),
          message: 'devices.details_empty_message'.tr(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: Text(device.brand)),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.page,
                AppSpacing.page,
                18,
              ),
              sliver: SliverToBoxAdapter(
                child: _DeviceHeroCard(device: device),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: SliverToBoxAdapter(
                child: AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'devices.specifications_title'.tr(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      if ((device.specifications.battery ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_battery'.tr(),
                          value: device.specifications.battery!,
                        ),
                      if ((device.specifications.camera ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_camera'.tr(),
                          value: device.specifications.camera!,
                        ),
                      if ((device.specifications.storage ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_storage'.tr(),
                          value: device.specifications.storage!,
                        ),
                      if ((device.specifications.ram ?? '').trim().isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_ram'.tr(),
                          value: device.specifications.ram!,
                        ),
                      if ((device.specifications.processor ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_processor'.tr(),
                          value: device.specifications.processor!,
                        ),
                      if ((device.specifications.performance ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_performance'.tr(),
                          value: device.specifications.performance!,
                        ),
                      if ((device.specifications.display ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_display'.tr(),
                          value: device.specifications.display!,
                        ),
                      if ((device.specifications.operatingSystem ?? '')
                          .trim()
                          .isNotEmpty)
                        DeviceSpecRow(
                          label: 'devices.spec_operating_system'.tr(),
                          value: device.specifications.operatingSystem!,
                        ),
                      if (!device.specifications.hasAnyValue)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'devices.no_specifications'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _DeviceHeroCard extends StatelessWidget {
  const _DeviceHeroCard({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadii.hero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: AppNetworkImage(
              imageUrl: device.imageUrl,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.hero),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.brand,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  device.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (device.releaseYear != null)
                      _InfoChip(
                        label:
                            '${'devices.release_year'.tr()}: ${device.releaseYear}',
                      ),
                    _InfoChip(
                      label: tr(
                        'devices.marketplace_count',
                        namedArgs: <String, String>{
                          'count': '${device.marketplaceProductsCount}',
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DeviceDetailsLoadingPage extends StatelessWidget {
  const _DeviceDetailsLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AppSkeleton(
              child: AppSkeletonBox(
                height: 320,
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.hero)),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: AppSkeleton(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(height: 18, width: 100),
                    SizedBox(height: AppSpacing.md),
                    AppSkeletonBox(height: 28, width: double.infinity),
                    SizedBox(height: AppSpacing.sm),
                    AppSkeletonBox(height: 18, width: 180),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
