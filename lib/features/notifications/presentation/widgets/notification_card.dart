import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_notification_item.dart';
import 'notification_unread_indicator.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.isBusy,
    required this.onTap,
    required this.onMarkAsRead,
    super.key,
  });

  final AppNotificationItem notification;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactInfo = _contactInfo(notification.meta);

    return InkWell(
      onTap: isBusy ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: notification.isRead
                ? theme.colorScheme.outlineVariant
                : theme.colorScheme.primary.withValues(alpha: 0.24),
          ),
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
                  if (!notification.isRead) ...[
                    const NotificationUnreadIndicator(),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      notification.title ?? 'notifications.untitled'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (notification.createdAt != null)
                    Text(
                      DateFormat('yyyy-MM-dd').format(notification.createdAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                notification.message ?? 'notifications.empty_message'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              if (contactInfo != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'notifications.contact_info_title'.tr(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if ((contactInfo['phone'] ?? '').toString().trim().isNotEmpty)
                        Text(
                          '${'profile.phone_label'.tr()}: ${contactInfo['phone']}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if ((contactInfo['email'] ?? '').toString().trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${'profile.email_label'.tr()}: ${contactInfo['email']}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _TypeChip(type: notification.type),
                  const Spacer(),
                  if (!notification.isRead)
                    TextButton(
                      onPressed: isBusy ? null : onMarkAsRead,
                      child: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('notifications.mark_as_read'.tr()),
                    )
                  else if (notification.hasAction || _hasImplicitRoute(notification))
                    TextButton(
                      onPressed: isBusy ? null : onTap,
                      child: Text('notifications.open_action'.tr()),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _contactInfo(Map<String, dynamic> meta) {
    final value = meta['contact_info'];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  bool _hasImplicitRoute(AppNotificationItem notification) {
    return notification.type == 'order' ||
        notification.type == 'action' ||
        notification.type == 'wallet';
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (type) {
      'device_offer' => (
          const Color(0xFFE0F2FE),
          const Color(0xFF0369A1),
          'notifications.type_device_offer'.tr(),
        ),
      'order' => (
          const Color(0xFFECFDF5),
          const Color(0xFF15803D),
          'notifications.type_order'.tr(),
        ),
      'action' => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          'notifications.type_action'.tr(),
        ),
      'wallet' => (
          const Color(0xFFF5F3FF),
          const Color(0xFF6D28D9),
          'notifications.type_wallet'.tr(),
        ),
      _ => (
          Theme.of(context).colorScheme.surfaceContainerHighest,
          Theme.of(context).colorScheme.onSurface,
          'notifications.type_system'.tr(),
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
