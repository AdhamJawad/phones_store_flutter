import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeviceRequestStatusBadge extends StatelessWidget {
  const DeviceRequestStatusBadge({
    required this.status,
    super.key,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (status) {
      'approved' => (
          const Color(0xFFECFDF5),
          const Color(0xFF15803D),
          'device_requests.status_approved'.tr(),
        ),
      'rejected' => (
          const Color(0xFFFEF2F2),
          const Color(0xFFB91C1C),
          'device_requests.status_rejected'.tr(),
        ),
      _ => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          'device_requests.status_pending'.tr(),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
