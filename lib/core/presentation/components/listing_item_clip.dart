import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';

class ListingItemClip extends StatelessWidget {
  const ListingItemClip({super.key, required this.label, this.icon, this.bg, this.onBg});

  final String label;
  final IconData? icon;
  final Color? bg;
  final Color? onBg;

  @override
  Widget build(BuildContext context) {
    final fg = onBg ?? context.colors.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
      decoration: ShapeDecoration(
        color: bg ?? context.appColors.background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg, semanticLabel: label),
            const SizedBox(width: Space.xs),
          ],
          Text(label.toUpperCase(), style: context.typos.labelLarge?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class PendingAlert extends StatelessWidget {
  const PendingAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.1),
        border: Border.all(color: colors.error, width: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 16, color: colors.error, semanticLabel: 'Pending'),
              const SizedBox(width: Space.xs),
              Text('Pending Approval', style: typos.labelMedium?.copyWith(color: colors.error)),
            ],
          ),
          SizedBox(height: 12, child: VerticalDivider(width: 1, color: colors.outlineVariant)),
          Flexible(
            child: Text(
              'Waiting for the approval.',
              style: typos.labelMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
