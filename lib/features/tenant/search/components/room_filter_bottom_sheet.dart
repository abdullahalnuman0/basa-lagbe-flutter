import 'package:flutter/material.dart';

import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../data/enums/enums.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../../../auth/signup/location_data.dart';
import '../../../owner/property_add_edit/components/location_section.dart';
import '../room_search_filter.dart';

typedef FilterUpdate = void Function(RoomSearchFilter Function(RoomSearchFilter old) transform);

class RoomFilterBottomSheet extends StatelessWidget {
  const RoomFilterBottomSheet({
    super.key,
    required this.filter,
    required this.onFilterChange,
    required this.onApply,
    required this.onClear,
    required this.onDismiss,
  });

  final RoomSearchFilter filter;
  final FilterUpdate onFilterChange;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final VoidCallback onDismiss;

  static String _digits(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return PopScope(
      canPop: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: typos.headlineMedium),
                          TextButton(
                            onPressed: onClear,
                            style: TextButton.styleFrom(foregroundColor: colors.error),
                            child: const Text('Clear all'),
                          ),
                        ],
                      ),
                      const Text('Location'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Space.lg,
                        children: [
                          Expanded(
                            child: LocationCard(
                              label: 'Division',
                              value: filter.division,
                              items: LocationData.divisions,
                              onSelect: (it) => onFilterChange((old) => old.copyWith(division: it)),
                            ),
                          ),
                          Expanded(
                            child: LocationCard(
                              label: 'District',
                              value: filter.district,
                              items: LocationData.districtByDivision[filter.division] ?? const [],
                              onSelect: (it) => onFilterChange((old) => old.copyWith(district: it)),
                            ),
                          ),
                        ],
                      ),
                      AuthInputTextField(
                        value: filter.area,
                        onValueChange: (it) => onFilterChange((old) => old.copyWith(area: it)),
                        placeholder: 'Area / Neighborhood',
                        icon: null,
                      ),
                      const Text('Room type'),
                      _ChipRow(
                        children: [
                          for (final type in RoomType.values)
                            FilterChip(
                              showCheckmark: false,
                              selected: filter.roomType == type,
                              onSelected: (_) => onFilterChange(
                                (old) => old.copyWith(roomType: old.roomType == type ? null : type),
                              ),
                              label: Text(type.name[0] + type.name.substring(1).toLowerCase()),
                            ),
                        ],
                      ),
                      const Text('Rent'),
                      _NumberPair(
                        first: filter.minRent,
                        firstHint: 'Min: e.g. 1000',
                        onFirstChange: (it) =>
                            onFilterChange((old) => old.copyWith(minRent: _digits(it))),
                        second: filter.maxRent,
                        secondHint: 'Max: e.g. 1200',
                        onSecondChange: (it) =>
                            onFilterChange((old) => old.copyWith(maxRent: _digits(it))),
                      ),
                      const Text('Available seats'),
                      _NumberPair(
                        first: filter.minAvailableSeats,
                        firstHint: 'Min seats',
                        onFirstChange: (it) =>
                            onFilterChange((old) => old.copyWith(minAvailableSeats: _digits(it))),
                        second: filter.maxAvailableSeats,
                        secondHint: 'Max seats',
                        onSecondChange: (it) =>
                            onFilterChange((old) => old.copyWith(maxAvailableSeats: _digits(it))),
                      ),
                      const Text('Minimum room size (ft)'),
                      _NumberPair(
                        first: filter.minRoomWidth,
                        firstHint: 'Min width',
                        onFirstChange: (it) =>
                            onFilterChange((old) => old.copyWith(minRoomWidth: _digits(it))),
                        second: filter.minRoomHeight,
                        secondHint: 'Min height',
                        onSecondChange: (it) =>
                            onFilterChange((old) => old.copyWith(minRoomHeight: _digits(it))),
                      ),
                      const Text('Sort by'),
                      _ChipRow(
                        children: [
                          for (final option in SortOption.values)
                            FilterChip(
                              showCheckmark: false,
                              selected: filter.sortBy == option,
                              onSelected: (_) =>
                                  onFilterChange((old) => old.copyWith(sortBy: option)),
                              label: Text(option.title),
                            ),
                        ],
                      ),
                      const Text('Order'),
                      _ChipRow(
                        children: [
                          for (final order in SortOrder.values)
                            FilterChip(
                              showCheckmark: false,
                              selected: filter.sortOrder == order,
                              onSelected: (_) =>
                                  onFilterChange((old) => old.copyWith(sortOrder: order)),
                              label: Text(order.title),
                            ),
                        ],
                      ),
                      const SizedBox(height: Space.screen),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Space.md),
                child: Row(
                  spacing: Space.md,
                  children: [
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(onPressed: onDismiss, child: const Text('Close')),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(onPressed: onApply, child: const Text('Apply filters')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(spacing: 8, children: children),
    );
  }
}

class _NumberPair extends StatelessWidget {
  const _NumberPair({
    required this.first,
    required this.firstHint,
    required this.onFirstChange,
    required this.second,
    required this.secondHint,
    required this.onSecondChange,
  });

  final String first;
  final String firstHint;
  final ValueChanged<String> onFirstChange;
  final String second;
  final String secondHint;
  final ValueChanged<String> onSecondChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.md,
      children: [
        Expanded(
          child: AuthInputTextField(
            value: first,
            onValueChange: onFirstChange,
            placeholder: firstHint,
            icon: null,
            keyboardType: TextInputType.number,
          ),
        ),
        Expanded(
          child: AuthInputTextField(
            value: second,
            onValueChange: onSecondChange,
            placeholder: secondHint,
            icon: null,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
