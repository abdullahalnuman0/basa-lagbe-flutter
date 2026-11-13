import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_card.dart';
import '../../../../core/presentation/widgets/shimmer.dart';
import '../../../../ui/theme/space.dart';

class PropertyDetailsShimmer extends StatelessWidget {
  const PropertyDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        spacing: Space.listGap,
        children: [
          _ImageShimmer(),
          _HeaderShimmer(),
          _StatsShimmer(),
          _AboutShimmer(),
          _FacilitiesShimmer(),
          SizedBox(height: Space.lg),
        ],
      ),
    );
  }
}

/// Large property image with the gallery controls on top.
class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShimmerBox(height: 220, radius: 0),
          // top-right action buttons
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(Space.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Space.sm,
                children: [
                  ShimmerBox(width: 38, height: 38, radius: 19),
                  ShimmerBox(width: 38, height: 38, radius: 19),
                ],
              ),
            ),
          ),
          // gallery button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(Space.md),
              child: ShimmerBox(widthFactor: 0.27, height: 30, radius: 15),
            ),
          ),
          // image counter
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(Space.md),
              child: ShimmerBox(widthFactor: 0.18, height: 24, radius: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title, approval badge, location and the type / gender chips.
class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Space.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.sm,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    ShimmerBox(widthFactor: 0.65, height: 20, radius: 8),
                    ShimmerBox(widthFactor: 0.42, height: 20, radius: 8),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: Space.sm),
                child: ShimmerBox(widthFactor: 0.27, height: 26, radius: 13),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Space.sm,
                children: [
                  ShimmerBox(width: 18, height: 18, radius: 9),
                  ShimmerBox(widthFactor: 0.55, height: 14),
                ],
              ),
              ShimmerBox(widthFactor: 0.18, height: 14),
            ],
          ),
          Row(
            spacing: Space.sm,
            children: [
              ShimmerBox(width: 70, height: 25, radius: 12.5),
              ShimmerBox(width: 60, height: 25, radius: 12.5),
              ShimmerBox(width: 75, height: 25, radius: 12.5),
            ],
          ),
        ],
      ),
    );
  }
}

/// Total rooms, available seats, starting rent and key facilities.
class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.screen),
      child: Column(
        spacing: Space.sm,
        children: [
          for (var i = 0; i < 2; i++)
            const Row(
              spacing: Space.sm,
              children: [
                Expanded(child: _StatCardShimmer()),
                Expanded(child: _StatCardShimmer()),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatCardShimmer extends StatelessWidget {
  const _StatCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Padding(
        padding: EdgeInsets.all(Space.md),
        child: Row(
          spacing: Space.sm,
          children: [
            ShimmerBox(width: 34, height: 34, radius: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  ShimmerBox(widthFactor: 0.55, height: 18),
                  ShimmerBox(widthFactor: 0.85, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutShimmer extends StatelessWidget {
  const _AboutShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Space.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.sm,
        children: [
          ShimmerBox(widthFactor: 0.45, height: 19, radius: 8),
          SizedBox(height: 2),
          ShimmerBox(height: 12),
          ShimmerBox(widthFactor: 0.95, height: 12),
          ShimmerBox(widthFactor: 0.72, height: 12),
        ],
      ),
    );
  }
}

class _FacilitiesShimmer extends StatelessWidget {
  const _FacilitiesShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.screen),
      child: Column(
        spacing: Space.sm,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(widthFactor: 0.55, height: 19, radius: 8),
              ShimmerBox(widthFactor: 0.18, height: 11),
            ],
          ),
          const SizedBox(height: 2),
          for (var i = 0; i < 4; i++)
            const Row(
              spacing: Space.sm,
              children: [
                Expanded(child: _FacilityItemShimmer()),
                Expanded(child: _FacilityItemShimmer()),
              ],
            ),
          // more amenities
          const ShimmerBox(widthFactor: 0.35, height: 14),
        ],
      ),
    );
  }
}

class _FacilityItemShimmer extends StatelessWidget {
  const _FacilityItemShimmer();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Space.sm, vertical: 10),
        child: Row(
          spacing: Space.sm,
          children: [
            ShimmerBox(width: 18, height: 18, radius: 9),
            Expanded(child: ShimmerBox(widthFactor: 0.65, height: 12)),
          ],
        ),
      ),
    );
  }
}
