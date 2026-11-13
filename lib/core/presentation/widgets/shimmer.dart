import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import '../components/app_card.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 6, this.row = false});

  final int count;
  final bool row;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Space.screen, vertical: Space.md),
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: Space.listGap),
            row ? const ShimmerRow() : const ShimmerCard(),
          ],
        ],
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  ShimmerBox(widthFactor: 0.22, height: 18, radius: 8),
                  SizedBox(width: Space.sm),
                  ShimmerBox(widthFactor: 0.18, height: 18, radius: 8),
                ],
              ),
              SizedBox(height: Space.sm),
              ShimmerBox(widthFactor: 0.85, height: 16),
              SizedBox(height: Space.sm),
              ShimmerBox(widthFactor: 0.55),
              SizedBox(height: Space.xs + Space.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [ShimmerBox(widthFactor: 0.30), ShimmerBox(widthFactor: 0.25)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerRow extends StatelessWidget {
  const ShimmerRow({super.key, this.avatar = true});

  final bool avatar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (avatar) ...[
                const ShimmerBox(width: 56, height: 56, radius: 8),
                const SizedBox(width: Space.md),
              ],
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: Space.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(widthFactor: 0.7, height: 16),
                      SizedBox(height: Space.sm),
                      ShimmerBox(widthFactor: 0.45),
                      SizedBox(height: Space.sm),
                      ShimmerBox(widthFactor: 0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A grey placeholder block with a moving highlight.
///
/// Give it either a fixed [width] or a [widthFactor] of the available width.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width, this.widthFactor, this.height = 14, this.radius = 4});

  final double? width;
  final double? widthFactor;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = colors.surfaceContainerHighest;
    final highlight = colors.surface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final width = widget.width ?? maxWidth * (widget.widthFactor ?? 1);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // highlight band travels from -500px to 1000px, 250px wide
            final x = -500 + 1500 * _controller.value;
            Alignment at(double px) => Alignment(width == 0 ? 0 : (px / width) * 2 - 1, 0);
            return Container(
              width: width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                gradient: LinearGradient(
                  begin: at(x),
                  end: at(x + 250),
                  colors: [base, highlight, base],
                  tileMode: TileMode.clamp,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
