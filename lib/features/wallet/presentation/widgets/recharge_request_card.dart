import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/recharge_method.dart';
import '../../domain/entities/recharge_request.dart';
import '../../domain/entities/recharge_request_status.dart';
import 'wallet_amount_text.dart';

class RechargeRequestCard extends StatelessWidget {
  const RechargeRequestCard({
    required this.request,
    super.key,
  });

  final RechargeRequest request;

  @override
  Widget build(BuildContext context) {
    final (background, color, label) = switch (request.status) {
      RechargeRequestStatus.pending => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          'wallet.request_pending'.tr(),
        ),
      RechargeRequestStatus.approved => (
          const Color(0xFFECFDF5),
          const Color(0xFF15803D),
          'wallet.request_approved'.tr(),
        ),
      RechargeRequestStatus.rejected => (
          const Color(0xFFFEF2F2),
          const Color(0xFFB91C1C),
          'wallet.request_rejected'.tr(),
        ),
      RechargeRequestStatus.unknown => (
          Theme.of(context).colorScheme.surfaceContainerHighest,
          Theme.of(context).colorScheme.onSurface,
          'wallet.request_unknown'.tr(),
        ),
    };

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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                WalletAmountText(
                  amount: request.amount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _methodLabel(request.paymentMethod).tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if ((request.adminNotes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.adminNotes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (request.proofImageUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: 76,
                height: 76,
                child: AppNetworkImage(
                  imageUrl: request.proofImageUrl,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _methodLabel(RechargeMethod method) {
    return switch (method) {
      RechargeMethod.syriatelCash => 'wallet.method_syriatel_cash',
      RechargeMethod.mtnCash => 'wallet.method_mtn_cash',
      RechargeMethod.stripe => 'wallet.method_stripe',
    };
  }
}
