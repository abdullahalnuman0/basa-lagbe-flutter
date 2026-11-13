import 'package:flutter/material.dart';

/// Paints a dashed rounded-rect outline on top of [child].
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.color,
    this.strokeWidth = 1,
    this.cornerRadius = 16,
    this.dashLength = 8,
    this.gapLength = 6,
    required this.child,
  });

  final Color color;
  final double strokeWidth;
  final double cornerRadius;
  final double dashLength;
  final double gapLength;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        cornerRadius: cornerRadius,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double cornerRadius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(cornerRadius)));

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.cornerRadius != cornerRadius ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
