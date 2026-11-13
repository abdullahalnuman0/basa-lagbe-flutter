import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';

class DropdownEntry {
  const DropdownEntry({
    required this.label,
    this.icon,
    this.destructive = false,
    required this.onClick,
    this.badged,
  });

  final String label;
  final IconData? icon;
  final bool destructive;
  final VoidCallback onClick;
  final int? badged;
}

/// Anchored popup menu. [anchorBuilder] receives a callback that toggles the menu.
class AppDropdownMenu extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    required this.entries,
    required this.anchorBuilder,
    this.header,
  });

  final List<DropdownEntry> entries;
  final Widget Function(BuildContext context, VoidCallback toggle) anchorBuilder;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MenuAnchor(
      alignmentOffset: const Offset(-120, 0),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      menuChildren: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
            child: header,
          ),
          Divider(color: colors.outlineVariant),
        ],
        for (final entry in entries)
          MenuItemButton(
            onPressed: entry.onClick,
            leadingIcon: entry.icon == null
                ? null
                : Badge(
                    isLabelVisible: (entry.badged ?? 0) > 0,
                    label: Text('${entry.badged ?? 0}'),
                    child: Icon(
                      entry.icon,
                      size: 20,
                      color: entry.destructive ? colors.error : colors.primary,
                    ),
                  ),
            child: Padding(
              padding: const EdgeInsets.only(right: Space.lg),
              child: Text(
                entry.label,
                style: context.typos.bodyLarge?.copyWith(
                  color: entry.destructive ? colors.error : colors.onSurface,
                ),
              ),
            ),
          ),
      ],
      builder: (context, controller, _) =>
          anchorBuilder(context, () => controller.isOpen ? controller.close() : controller.open()),
    );
  }
}
