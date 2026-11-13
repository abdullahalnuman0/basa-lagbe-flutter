import 'package:flutter/material.dart';

import '../../../../../core/presentation/components/app_card.dart';
import '../../../../../core/presentation/components/messages.dart';
import '../../../../../core/presentation/components/room_image.dart';
import '../../../../../domain/model/room.dart';
import '../../../../../ui/theme/space.dart';
import '../../../../../ui/theme/theme.dart';

class RoomViewerCard extends StatelessWidget {
  const RoomViewerCard({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final muted = colors.onSurface.withValues(alpha: 0.5);

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.lg, Space.xxl, Space.lg, Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.md,
          children: [
            // --- room number & type
            Row(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  color: colors.primary,
                  semanticLabel: 'RoomNumber',
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    room.roomNumber,
                    style: typos.headlineMedium?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    room.type?.name ?? '',
                    style: typos.labelSmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),

            // --- rent & deposit
            Wrap(
              spacing: Space.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '৳ ${room.rent}',
                      style: typos.headlineMedium?.copyWith(color: colors.primary),
                    ),
                    const SizedBox(width: Space.xs),
                    Text(
                      '/ month',
                      style: typos.labelMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: muted,
                      ),
                    ),
                  ],
                ),
                const _Dot(),
                Text(
                  'Deposit: ৳ ${room.deposit}',
                  style: typos.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: muted),
                ),
              ],
            ),

            // --- available seats & room size
            Wrap(
              spacing: Space.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PulsingDot(),
                    const SizedBox(width: Space.xs),
                    Text(
                      '${room.availableSeats} seats available',
                      style: typos.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const _Dot(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.straighten_outlined,
                      size: 16,
                      color: muted,
                      semanticLabel: 'RoomSize',
                    ),
                    const SizedBox(width: Space.xs),
                    Text(
                      '${room.roomWidth} x ${room.roomHeight} ft',
                      style: typos.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: muted),
                    ),
                  ],
                ),
              ],
            ),

            Text(
              'Attached Photos (${room.images.length})',
              style: typos.labelSmall?.copyWith(color: muted),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: room.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RoomImage(fileKey: room.images[index], fit: BoxFit.fill),
                        if (index == 0)
                          Positioned(
                            left: Space.xs,
                            bottom: Space.xs,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Space.sm,
                                vertical: Space.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Primary',
                                style: typos.labelSmall?.copyWith(color: colors.onPrimary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const AppDivider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: colors.primary),
                  label: const Text('Edit Room'),
                ),
                IconButton(
                  onPressed: () => showDeleteConfirmationDialog(context, onConfirm: onDelete),
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline, color: colors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimmed = Color.lerp(colors.primary, colors.onSurface, 0.5)!;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Color.lerp(colors.primary, dimmed, _progress.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
