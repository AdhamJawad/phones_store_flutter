import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ListingStatusBadge extends StatelessWidget {
  const ListingStatusBadge({
    required this.status,
    super.key,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (status) {
      'available' => (
          const Color(0xFFECFDF5),
          const Color(0xFF15803D),
          'seller.status_available'.tr(),
        ),
      'sold' => (
          const Color(0xFFE0F2FE),
          const Color(0xFF0369A1),
          'seller.status_sold'.tr(),
        ),
      'hidden' => (
          const Color(0xFFF3F4F6),
          const Color(0xFF4B5563),
          'seller.status_hidden'.tr(),
        ),
      'rejected' => (
          const Color(0xFFFEF2F2),
          const Color(0xFFB91C1C),
          'seller.status_rejected'.tr(),
        ),
      _ => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          'seller.status_pending'.tr(),
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
