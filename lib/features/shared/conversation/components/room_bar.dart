import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../data/dto/tenant/tenant_dtos.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import 'room_bar_content.dart';

class RoomBar extends StatefulWidget {
  const RoomBar({super.key, required this.room});

  final RoomTenantResponse room;

  @override
  State<RoomBar> createState() => _RoomBarState();
}

class _RoomBarState extends State<RoomBar> {
  bool _expanded = true;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      layoutBuilder: (current, previous) =>
          Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
      child: _expanded
          ? RoomBarContent(key: const ValueKey('expanded'), room: widget.room, onClick: _toggle)
          : Align(
              key: const ValueKey('collapsed'),
              alignment: Alignment.topLeft,
              child: _CollapsedButton(onClick: _toggle),
            ),
    );
  }
}

class _CollapsedButton extends StatelessWidget {
  const _CollapsedButton({required this.onClick});

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: Space.xs, top: Space.xs),
      child: SizedBox.square(
        dimension: 32,
        child: CustomPaint(
          foregroundPainter: const _GlassRingPainter(),
          child: Material(
            color: colors.surface.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onClick,
              child: Center(
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: Icon(
                    Icons.expand_less,
                    size: 20,
                    color: colors.onSurface,
                    semanticLabel: 'Back',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassRingPainter extends CustomPainter {
  const _GlassRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0.12)],
      ).createShader(rect);
    canvas.drawOval(rect.deflate(0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
