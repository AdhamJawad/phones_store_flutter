import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WalletAmountText extends StatelessWidget {
  const WalletAmountText({
    required this.amount,
    super.key,
    this.style,
  });

  final double amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${amount.toStringAsFixed(0)} ${'products.currency'.tr()}',
      style: style,
    );
  }
}
