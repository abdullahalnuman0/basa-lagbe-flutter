import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_card.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

typedef PropertyStat = ({String label, String value, IconData icon});

class PropertyStats extends StatelessWidget {
  const PropertyStats({super.key, required this.stats});

  final List<PropertyStat> stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.screen),
      child: Column(
        spacing: Space.listGap,
        children: [
          for (var i = 0; i < stats.length; i += 2)
            Row(
              spacing: Space.listGap,
              children: [
                for (final stat in stats.skip(i).take(2)) Expanded(child: _StatsCard(stat: stat)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stat});

  final PropertyStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Row(
          spacing: Space.sm,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(Space.xs),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                stat.icon,
                color: colors.onSurface.withValues(alpha: 0.7),
                semanticLabel: stat.label,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: context.typos.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Opacity(opacity: 0.7, child: Text(stat.label, style: context.typos.labelMedium)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
