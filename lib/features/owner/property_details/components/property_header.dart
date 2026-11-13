import 'package:flutter/material.dart';

import '../../../../core/presentation/components/messages.dart';
import '../../../../domain/enums/property_gender.dart';
import '../../../../domain/enums/property_type.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class PropertyHeader extends StatelessWidget {
  const PropertyHeader({
    super.key,
    required this.title,
    required this.approved,
    required this.location,
    required this.type,
    required this.gender,
    required this.error,
  });

  final String title;
  final bool approved;
  final String location;
  final PropertyType type;
  final PropertyGender gender;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final muted = colors.onSurface.withValues(alpha: 0.5);

    return Material(
      color: colors.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(Space.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.sm,
          children: [
            ErrorBoxMessage(error: error),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, style: typos.titleLarge)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                  decoration: ShapeDecoration(
                    color: approved ? colors.primaryContainer : colors.errorContainer,
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Space.xs,
                    children: [
                      if (approved)
                        const _LiveDot()
                      else
                        const Icon(Icons.error_outline, size: 8, semanticLabel: 'Pending'),
                      Text(approved ? 'Approved & Live' : 'Pending', style: typos.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              spacing: Space.xs,
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: muted),
                Expanded(
                  child: Text(location, style: typos.labelMedium?.copyWith(color: muted)),
                ),
              ],
            ),
            Row(spacing: Space.xs, children: [_HeaderChip(type.name), _HeaderChip(gender.name)]),
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  late final _curve = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final from = colors.primary;
    final to = Color.lerp(colors.primary, colors.onSurface, 0.5)!;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Color.lerp(from, to, _curve.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: context.typos.labelSmall?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
