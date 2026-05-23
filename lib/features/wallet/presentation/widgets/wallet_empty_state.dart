import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_state.dart';

class WalletEmptyState extends StatelessWidget {
  const WalletEmptyState({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: message,
      icon: Icons.account_balance_wallet_outlined,
      compact: true,
    );
  }
}
