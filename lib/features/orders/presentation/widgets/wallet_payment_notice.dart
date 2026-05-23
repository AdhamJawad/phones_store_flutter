import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/domain/entities/wallet_summary.dart';
import '../../../wallet/presentation/widgets/wallet_amount_text.dart';

class WalletPaymentNotice extends StatelessWidget {
  const WalletPaymentNotice({
    required this.walletSummary,
    required this.totalPrice,
    required this.active,
    super.key,
  });

  final AsyncValue<WalletSummary?> walletSummary;
  final double totalPrice;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.20)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: walletSummary.when(
          loading: () => Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'orders.wallet_balance_loading'.tr(),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          error: (_, _) => _WalletMessage(
            title: 'orders.wallet_balance_title'.tr(),
            message: 'orders.wallet_balance_unavailable'.tr(),
            toneColor: theme.colorScheme.onSurfaceVariant,
          ),
          data: (summary) {
            if (summary == null) {
              return _WalletMessage(
                title: 'orders.wallet_balance_title'.tr(),
                message: 'orders.wallet_balance_unavailable'.tr(),
                toneColor: theme.colorScheme.onSurfaceVariant,
              );
            }

            final isInsufficient = summary.balance < totalPrice;
            final toneColor = isInsufficient
                ? theme.colorScheme.error
                : const Color(0xFF15803D);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'orders.wallet_balance_title'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    WalletAmountText(
                      amount: summary.balance,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  active
                      ? isInsufficient
                          ? 'orders.wallet_insufficient_message'.tr()
                          : 'orders.wallet_sufficient_message'.tr()
                      : 'orders.wallet_balance_hint'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: active ? toneColor : theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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

class _WalletMessage extends StatelessWidget {
  const _WalletMessage({
    required this.title,
    required this.message,
    required this.toneColor,
  });

  final String title;
  final String message;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: toneColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
