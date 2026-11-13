import 'package:flutter/material.dart';

import '../../../../../core/presentation/components/search_field.dart';
import '../../../../../ui/theme/space.dart';
import '../../../../../ui/theme/theme.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({
    super.key,
    required this.totalRoom,
    required this.searchText,
    required this.onAdd,
    required this.onSearchChange,
    required this.onSearchClear,
  });

  final int totalRoom;
  final String searchText;
  final VoidCallback onAdd;
  final ValueChanged<String> onSearchChange;
  final VoidCallback onSearchClear;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rooms ($totalRoom)', style: typos.titleLarge),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Manage capacity, rent and availability',
                    style: typos.labelMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_outlined, semanticLabel: 'AddRoom'),
              label: const Text('Add Room'),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        SearchField(value: searchText, onValueChange: onSearchChange, onClear: onSearchClear),
      ],
    );
  }
}
