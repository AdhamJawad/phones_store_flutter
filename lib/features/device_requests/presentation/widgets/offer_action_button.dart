import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OfferActionButton extends StatelessWidget {
  const OfferActionButton({
    required this.isBusy,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final bool isBusy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled && !isBusy ? onPressed : null,
      child: isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          : Text('device_requests.offer_cta'.tr()),
    );
  }
}
