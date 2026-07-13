import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/routing/app_routes.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: 40,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () => _handleBack(context),
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ),
      ),
    );
  }
}
