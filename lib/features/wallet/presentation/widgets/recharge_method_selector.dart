import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/recharge_method.dart';

class RechargeMethodSelector extends StatelessWidget {
  const RechargeMethodSelector({
    required this.selectedMethod,
    required this.onChanged,
    super.key,
  });

  final RechargeMethod selectedMethod;
  final ValueChanged<RechargeMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final methods = RechargeMethod.values;
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
                  const SizedBox(width: 10),
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

  String _label(RechargeMethod method) {
    return switch (method) {
      RechargeMethod.syriatelCash => 'wallet.method_syriatel_cash',
      RechargeMethod.mtnCash => 'wallet.method_mtn_cash',
      RechargeMethod.stripe => 'wallet.method_stripe',
    };
  }

  String _subtitle(RechargeMethod method) {
    return switch (method) {
      RechargeMethod.syriatelCash => 'wallet.method_syriatel_cash_subtitle',
      RechargeMethod.mtnCash => 'wallet.method_mtn_cash_subtitle',
      RechargeMethod.stripe => 'wallet.method_stripe_subtitle',
    };
  }
}
