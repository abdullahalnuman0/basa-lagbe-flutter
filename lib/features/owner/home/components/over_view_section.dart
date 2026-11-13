import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class OverViewData {
  const OverViewData(this.title, this.value, this.icon, this.color);

  final String title;
  final int value;
  final IconData icon;
  final Color color;
}

class OverViewSection extends StatelessWidget {
  const OverViewSection({super.key, required this.overViews});

  final List<OverViewData> overViews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: context.typos.labelLarge?.copyWith(fontWeight: FontWeight.normal)),
        const SizedBox(height: Space.sm),
        Column(
          spacing: Space.listGap,
          children: [
            for (var i = 0; i < overViews.length; i += 2)
              Row(
                spacing: Space.listGap,
                children: [
                  for (final item in overViews.skip(i).take(2))
                    Expanded(child: _OverViewCard(item: item)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _OverViewCard extends StatelessWidget {
  const _OverViewCard({required this.item});

  final OverViewData item;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;
    return SectionCard(
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: typos.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 16, color: item.color, semanticLabel: item.title),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Text(
          '${item.value}',
          style: typos.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: item.color),
        ),
      ],
    );
  }
}
