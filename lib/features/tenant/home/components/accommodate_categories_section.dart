import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class _AccommodateCategory {
  const _AccommodateCategory(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

const _items = [
  _AccommodateCategory('Boys Hostel', 'Male Hostels'),
  _AccommodateCategory('Girls Hostel', 'Female Hostels'),
  _AccommodateCategory('Independent Flat', 'Full flats'),
  _AccommodateCategory('Bachelor Sublet', 'Bachelors mess'),
  _AccommodateCategory('Family Homes', 'Family suites'),
  _AccommodateCategory('Attached Bath AC', 'Premium luxury'),
];

// Colors that read well on a light background
const _colorPalette = [
  Color(0xFF2563EB), // Blue
  Color(0xFF7C3AED), // Purple
  Color(0xFF0F766E), // Teal
  Color(0xFFBE123C), // Rose
  Color(0xFFB45309), // Amber
  Color(0xFF4D7C0F), // Green
  Color(0xFF4338CA), // Indigo
  Color(0xFF0E7490), // Cyan
];

class AccommodateCategoriesSection extends StatefulWidget {
  const AccommodateCategoriesSection({super.key, required this.onClick});

  final VoidCallback onClick;

  @override
  State<AccommodateCategoriesSection> createState() => _AccommodateCategoriesSectionState();
}

class _AccommodateCategoriesSectionState extends State<AccommodateCategoriesSection> {
  late final List<Color> _colors = _randomColors();

  static List<Color> _randomColors() {
    final random = Random();
    if (_items.length <= _colorPalette.length) {
      return ([..._colorPalette]..shuffle(random)).take(_items.length).toList();
    }
    return List.generate(_items.length, (_) => _colorPalette[random.nextInt(_colorPalette.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.md,
      children: [
        Text(
          'Accommodate Categories'.toUpperCase(),
          style: context.typos.labelLarge?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.8),
          ),
        ),
        for (var row = 0; row * 3 < _items.length; row++)
          Row(
            spacing: Space.md,
            children: [
              for (var i = row * 3; i < min(row * 3 + 3, _items.length); i++)
                Expanded(
                  child: _Item(item: _items[i], color: _colors[i], onClick: widget.onClick),
                ),
            ],
          ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.color, required this.onClick});

  final _AccommodateCategory item;
  final Color color;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;

    return SizedBox(
      height: 100,
      child: SectionCard(
        onClick: onClick,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typos.labelMedium?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typos.labelSmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
