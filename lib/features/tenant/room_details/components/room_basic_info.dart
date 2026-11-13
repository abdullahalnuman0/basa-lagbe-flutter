import 'package:flutter/material.dart';

import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class RoomBasicInfo extends StatelessWidget {
  const RoomBasicInfo({
    super.key,
    required this.title,
    required this.roomNumber,
    required this.location,
    required this.institutionNearby,
    required this.roomSize,
    required this.totalSeats,
  });

  final String title;
  final String roomNumber;
  final String location;
  final String institutionNearby;
  final String roomSize;
  final int totalSeats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            children: [
              TextSpan(
                text: '($roomNumber)',
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontSize: typos.bodyMedium?.fontSize,
                ),
              ),
            ],
          ),
          style: typos.headlineLarge,
        ),
        const SizedBox(height: Space.xl),
        Row(
          spacing: Space.xs,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.red,
              semanticLabel: 'location',
            ),
            Expanded(
              child: Text(
                location,
                style: typos.labelLarge?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.xs),
        if (institutionNearby.length > 3)
          Row(
            spacing: Space.xs,
            children: [
              Icon(
                Icons.school_outlined,
                size: 16,
                color: colors.primary,
                semanticLabel: 'institution',
              ),
              Expanded(
                child: Text(
                  institutionNearby,
                  style: typos.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: Space.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Meta(icon: Icons.straighten_outlined, text: '$roomSize ft'),
            SizedBox(
              height: 12,
              child: VerticalDivider(width: 1, color: colors.onSurface.withValues(alpha: 0.2)),
            ),
            _Meta(icon: Icons.hotel_outlined, text: '$totalSeats Available Seats'),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Space.xs,
      children: [
        Icon(icon, size: 16),
        Text(text, style: context.typos.labelMedium),
      ],
    );
  }
}
