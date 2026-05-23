import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../home/domain/entities/device_request.dart';
import 'device_request_status_badge.dart';
import 'offer_action_button.dart';

class MarketplaceDeviceRequestCard extends StatelessWidget {
  const MarketplaceDeviceRequestCard({
    required this.request,
    super.key,
    this.canOffer = false,
    this.isOwnRequest = false,
    this.isOffering = false,
    this.onOffer,
  });

  final DeviceRequest request;
  final bool canOffer;
  final bool isOwnRequest;
  final bool isOffering;
  final VoidCallback? onOffer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.phone_android_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.brand} ${request.model}',
                        style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.user?.name ?? 'home.unknown_user'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                DeviceRequestStatusBadge(status: request.status),
              ],
            ),
            if ((request.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                request.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (request.createdAt != null)
                  Text(
                    DateFormat('yyyy-MM-dd').format(request.createdAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                const Spacer(),
                if (canOffer)
                  OfferActionButton(
                    isBusy: isOffering,
                    enabled: !isOwnRequest,
                    onPressed: onOffer ?? () {},
                  )
                else if (isOwnRequest)
                  Text(
                    'device_requests.own_request_hint'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
