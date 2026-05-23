import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_payment_method.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.methods,
    required this.selectedMethod,
    required this.onChanged,
    super.key,
  });

  final List<OrderPaymentMethod> methods;
  final OrderPaymentMethod selectedMethod;
  final ValueChanged<OrderPaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: methods.map((method) {
        final selected = method == selectedMethod;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onChanged(method),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label(method).tr(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle(method).tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  String _label(OrderPaymentMethod method) {
    return switch (method) {
      OrderPaymentMethod.wallet => 'orders.payment_wallet',
      OrderPaymentMethod.stripe => 'orders.payment_stripe',
      OrderPaymentMethod.cod => 'orders.payment_cod',
    };
  }

  String _subtitle(OrderPaymentMethod method) {
    return switch (method) {
      OrderPaymentMethod.wallet => 'orders.payment_wallet_subtitle',
      OrderPaymentMethod.stripe => 'orders.payment_stripe_subtitle',
      OrderPaymentMethod.cod => 'orders.payment_cod_subtitle',
    };
  }
}
