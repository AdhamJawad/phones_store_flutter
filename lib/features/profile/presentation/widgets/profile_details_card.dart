import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/profile_user.dart';

class ProfileDetailsCard extends StatelessWidget {
  const ProfileDetailsCard({
    required this.profile,
    super.key,
  });

  final ProfileUser profile;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'profile.account_summary_title'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _Row(label: 'profile.username_label'.tr(), value: profile.username),
            _Row(label: 'profile.phone_label'.tr(), value: profile.phone),
            _Row(label: 'profile.location_label'.tr(), value: profile.location),
            _Row(label: 'profile.gender_label'.tr(), value: profile.gender),
            _Row(
              label: 'profile.birth_date_label'.tr(),
              value: profile.dateOfBirth,
            ),
            _Row(
              label: 'profile.email_verified_label'.tr(),
              value: profile.emailVerifiedAt == null
                  ? 'profile.not_verified'.tr()
                  : 'profile.verified'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = (value ?? '').trim().isEmpty
        ? 'profile.not_available'.tr()
        : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              display,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
