import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../device_catalog/domain/entities/device.dart';
import '../providers/device_compare_providers.dart';

class DeviceComparePage extends ConsumerStatefulWidget {
  const DeviceComparePage({super.key});

  @override
  ConsumerState<DeviceComparePage> createState() => _DeviceComparePageState();
}

class _DeviceComparePageState extends ConsumerState<DeviceComparePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceCompareControllerProvider);
    final controller = ref.read(deviceCompareControllerProvider.notifier);

    if (_searchController.text != state.searchQuery) {
      _searchController.value = TextEditingValue(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    final selectedDevices = state.availableDevices
        .where((device) => state.selectedDeviceIds.contains(device.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('compare.title'.tr()),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadOptions,
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
                'compare.title'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'compare.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'compare.search_hint'.tr(),
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'compare.selected_title'.tr(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (state.selectedDeviceIds.isNotEmpty)
                          TextButton(
                            onPressed: controller.clearSelection,
                            child: Text('compare.clear_selection'.tr()),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.generate(2, (index) {
                        final device = index < selectedDevices.length
                            ? selectedDevices[index]
                            : null;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: index == 0 ? AppSpacing.sm : 0,
                            ),
                            child: _SelectedDeviceSlot(
                              device: device,
                              slotIndex: index,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.canCompare
                            ? () => context.push(
                                AppRoutes.deviceCompareResult,
                                extra: state.selectedDeviceIds,
                              )
                            : null,
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: Text('compare.compare_cta'.tr()),
                      ),
                    ),
                    if (state.hasError) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              if (state.isLoadingOptions)
                const _OptionsLoading()
              else if (state.hasError && state.availableDevices.isEmpty)
                AppErrorState(
                  title: 'compare.options_error_title'.tr(),
                  message: state.errorMessage!,
                  actionLabel: 'common.retry'.tr(),
                  onRetry: controller.loadOptions,
                )
              else if (state.filteredDevices.isEmpty)
                AppEmptyState(
                  title: 'compare.empty_title'.tr(),
                  message: 'compare.empty_message'.tr(),
                  compact: true,
                )
              else
                _DeviceSelectionList(
                  items: state.filteredDevices,
                  selectedDeviceIds: state.selectedDeviceIds,
                  onToggle: controller.toggleDevice,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDeviceSlot extends StatelessWidget {
  const _SelectedDeviceSlot({required this.device, required this.slotIndex});

  final Device? device;
  final int slotIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDevice = device;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: selectedDevice == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'compare.device_label'.tr()} ${slotIndex + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'compare.select_placeholder'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDevice.brand,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedDevice.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DeviceSelectionList extends StatelessWidget {
  const _DeviceSelectionList({
    required this.items,
    required this.selectedDeviceIds,
    required this.onToggle,
  });

  final List<Device> items;
  final List<int> selectedDeviceIds;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        children: items
            .map((device) {
              final selected = selectedDeviceIds.contains(device.id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () => onToggle(device.id),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: AppNetworkImage(
                            imageUrl: device.imageUrl,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.brand,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                device.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                device.specifications.processor ??
                                    device.specifications.display ??
                                    '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _OptionsLoading extends StatelessWidget {
  const _OptionsLoading();

  @override
  Widget build(BuildContext context) {
    return const AppSurfaceCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
