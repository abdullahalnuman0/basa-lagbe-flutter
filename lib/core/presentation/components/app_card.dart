import 'package:flutter/material.dart';

import '../../../ui/theme/theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, this.onClick, this.border, required this.child});

  final VoidCallback? onClick;
  final double? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: border == null
          ? BorderSide.none
          : BorderSide(color: colors.outlineVariant, width: border!),
    );
    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onClick == null ? child : InkWell(onTap: onClick, child: child),
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: context.colors.outlineVariant);
  }
}
