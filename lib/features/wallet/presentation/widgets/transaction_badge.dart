import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/wallet_transaction_type.dart';

class TransactionBadge extends StatelessWidget {
  const TransactionBadge({
    required this.type,
    super.key,
  });

  final WalletTransactionType type;

  @override
  Widget build(BuildContext context) {
    final (background, color, label) = switch (type) {
      WalletTransactionType.deposit => (
          const Color(0xFFECFDF5),
          const Color(0xFF15803D),
          'wallet.transaction_deposit'.tr(),
        ),
      WalletTransactionType.withdraw => (
          const Color(0xFFFEF2F2),
          const Color(0xFFB91C1C),
          'wallet.transaction_withdraw'.tr(),
        ),
      WalletTransactionType.credit => (
          const Color(0xFFE0F2FE),
          const Color(0xFF0369A1),
          'wallet.transaction_credit'.tr(),
        ),
      WalletTransactionType.unknown => (
          Theme.of(context).colorScheme.surfaceContainerHighest,
          Theme.of(context).colorScheme.onSurface,
          'wallet.transaction_unknown'.tr(),
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
