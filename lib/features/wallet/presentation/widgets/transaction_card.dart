import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/wallet_transaction.dart';
import '../../domain/entities/wallet_transaction_type.dart';
import 'transaction_badge.dart';
import 'wallet_amount_text.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    required this.transaction,
    super.key,
  });

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type == WalletTransactionType.deposit ||
        transaction.type == WalletTransactionType.credit;
    final amountStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isPositive
              ? const Color(0xFF15803D)
              : Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w900,
        );

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
                  child: TransactionBadge(type: transaction.type),
                ),
                RichText(
                  text: TextSpan(
                    style: amountStyle,
                    children: [
                      TextSpan(text: isPositive ? '+' : '-'),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: WalletAmountText(
                          amount: transaction.amount,
                          style: amountStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              transaction.description ?? transaction.reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${'wallet.balance_before'.tr()}: ${transaction.balanceBefore.toStringAsFixed(0)} | ${'wallet.balance_after'.tr()}: ${transaction.balanceAfter.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (transaction.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(transaction.createdAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
