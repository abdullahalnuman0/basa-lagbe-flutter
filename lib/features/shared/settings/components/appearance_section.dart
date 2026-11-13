import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../domain/enums/theme_mode.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key, required this.selectedTheme, required this.onThemeMode});

  final AppThemeMode selectedTheme;
  final ValueChanged<AppThemeMode> onThemeMode;

  static const _options = [
    (AppThemeMode.SYSTEM, 'System', Icons.brightness_auto_rounded),
    (AppThemeMode.LIGHT, 'Light', Icons.light_mode_rounded),
    (AppThemeMode.DARK, 'Dark', Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Appearance'),
        const SizedBox(height: 4),
        SectionCard(
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppThemeMode>(
                showSelectedIcon: false,
                selected: {selectedTheme},
                onSelectionChanged: (selection) => onThemeMode(selection.first),
                segments: [
                  for (final (mode, label, icon) in _options)
                    ButtonSegment(value: mode, label: Text(label), icon: Icon(icon, size: 18)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
