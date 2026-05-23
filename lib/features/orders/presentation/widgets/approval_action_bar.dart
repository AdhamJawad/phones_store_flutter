import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ApprovalActionBar extends StatelessWidget {
  const ApprovalActionBar({
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isBusy ? null : onReject,
            child: Text('orders.reject_action'.tr()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isBusy ? null : onApprove,
            child: Text('orders.approve_action'.tr()),
          ),
        ),
      ],
    );
  }
}
