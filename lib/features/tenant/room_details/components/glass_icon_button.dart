import 'package:flutter/material.dart';

import '../../../../ui/theme/theme.dart';

/// Small round translucent button that floats over the room photo.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox.square(
      dimension: 40,
      child: Material(
        color: colors.surface.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: CustomPaint(
            painter: _RingPainter(),
            child: Center(
              child: Icon(icon, color: colors.onSurface, semanticLabel: semanticLabel),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0.12)],
      ).createShader(rect);
    canvas.drawOval(rect.deflate(0.5), paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}
