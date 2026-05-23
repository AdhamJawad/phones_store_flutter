import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/app_empty_state.dart';

class ShellPlaceholderPage extends StatelessWidget {
  const ShellPlaceholderPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: icon,
              compact: true,
              actionLabel: 'common.coming_soon'.tr(),
              onAction: () {},
            ),
          ),
        ],
      ),
    );
  }
}
