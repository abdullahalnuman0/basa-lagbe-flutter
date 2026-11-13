import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/shimmer.dart';
import '../../../../ui/theme/space.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(Space.md),
      child: Column(
        spacing: Space.listGap,
        children: [
          _GreetingShimmer(),
          _AddBtnShimmer(),
          _OverviewShimmer(),
          _YourRoomsShimmer(),
          _ChipBtnShimmer(),
          _RoomItemShimmer(),
          _RoomItemShimmer(),
        ],
      ),
    );
  }
}

class _RoomItemShimmer extends StatelessWidget {
  const _RoomItemShimmer();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: const Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ShimmerBox(height: 180, radius: 0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(Space.listGap),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Space.listGap,
                      children: [
                        ShimmerBox(widthFactor: 0.2, height: 20, radius: 10),
                        ShimmerBox(widthFactor: 0.2, height: 20, radius: 10),
                      ],
                    ),
                  ),
                ),
                // top-right actions
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(Space.listGap),
                    child: ShimmerBox(widthFactor: 0.2, height: 20, radius: 10),
                  ),
                ),
                // bottom-start location
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(Space.listGap),
                    child: ShimmerBox(widthFactor: 0.5, height: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(Space.sm), child: _GreetingShimmer()),
        ],
      ),
    );
  }
}

class _ChipBtnShimmer extends StatelessWidget {
  const _ChipBtnShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: Space.listGap,
      children: [
        ShimmerBox(widthFactor: 0.2, height: 28, radius: 8),
        ShimmerBox(widthFactor: 0.2, height: 28, radius: 8),
        ShimmerBox(widthFactor: 0.2, height: 28, radius: 8),
      ],
    );
  }
}

class _YourRoomsShimmer extends StatelessWidget {
  const _YourRoomsShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerBox(widthFactor: 0.2, height: 20),
        ShimmerBox(widthFactor: 0.15, height: 16),
      ],
    );
  }
}

class _OverviewShimmer extends StatelessWidget {
  const _OverviewShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.listGap,
      children: [
        const ShimmerBox(widthFactor: 0.2, height: 16),
        for (var i = 0; i < 2; i++)
          const Row(
            spacing: Space.listGap,
            children: [
              Expanded(child: ShimmerBox(height: 80, radius: 16)),
              Expanded(child: ShimmerBox(height: 80, radius: 16)),
            ],
          ),
      ],
    );
  }
}

class _AddBtnShimmer extends StatelessWidget {
  const _AddBtnShimmer();

  @override
  Widget build(BuildContext context) => const ShimmerBox(height: 80, radius: 16);
}

class _GreetingShimmer extends StatelessWidget {
  const _GreetingShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(widthFactor: 0.7, height: 24),
        SizedBox(height: Space.md),
        ShimmerBox(widthFactor: 0.5, height: 16),
      ],
    );
  }
}
