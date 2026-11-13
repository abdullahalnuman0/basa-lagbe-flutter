import 'package:flutter/material.dart';

import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class FeedTabs extends StatelessWidget {
  const FeedTabs({
    super.key,
    required this.totalRoom,
    required this.approved,
    required this.pending,
    required this.selected,
    required this.onSelect,
  });

  final int totalRoom;
  final int approved;
  final int pending;
  final int selected;
  final ValueChanged<int> onSelect;

  static String _label(String name, int count) => count > 0 ? '$name ($count)' : name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tabs = [
      _label('All', totalRoom),
      _label('Approved', approved),
      _label('Pending', pending),
    ];

    return Wrap(
      spacing: Space.sm,
      children: [
        for (final (index, label) in tabs.indexed)
          FilterChip(
            selected: index == selected,
            showCheckmark: false,
            onSelected: (_) => onSelect(index),
            selectedColor: colors.primary,
            label: Text(
              label,
              style: context.typos.labelLarge?.copyWith(
                color: index == selected ? colors.onPrimary : null,
              ),
            ),
          ),
      ],
    );
  }
}
