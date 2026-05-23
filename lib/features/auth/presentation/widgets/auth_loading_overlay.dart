import 'package:flutter/material.dart';

class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({
    required this.isVisible,
    required this.child,
    super.key,
  });

  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.08),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
      ],
    );
  }
}
