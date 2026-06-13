import 'package:flutter/material.dart';

import '../constants/app_tokens.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );
  }
}
