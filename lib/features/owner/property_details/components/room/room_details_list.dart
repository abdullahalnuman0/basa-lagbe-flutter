import 'package:flutter/material.dart';

import '../../../../../core/presentation/components/app_card.dart';
import '../../../../../core/presentation/components/room_image.dart';
import '../../../../../core/presentation/widgets/empty_box.dart';
import '../../../../../core/utils/functions.dart';
import '../../../../../data/dto/room/room_dtos.dart';
import '../../../../../ui/theme/space.dart';
import '../../../../../ui/theme/theme.dart';

class RoomDetailsList extends StatelessWidget {
  const RoomDetailsList({
    super.key,
    required this.searchText,
    required this.rooms,
    required this.onEdit,
    required this.onAvailability,
  });

  final String searchText;

  /// Rooms to show, paired with their position in the property's room list.
  final List<(int, RoomResponse)> rooms;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onAvailability;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      final isSearching = searchText.trim().isNotEmpty;
      return EmptyBox(
        title: isSearching ? 'No rooms found' : 'No rooms available',
        subtitle: isSearching
            ? "No room matches '$searchText'. Try a different room number."
            : 'Add a room to start managing your property.',
        icon: isSearching ? Icons.search_off_outlined : Icons.door_back_door_outlined,
      );
    }

    return Column(
      spacing: Space.listGap,
      children: [
        for (final (index, room) in rooms)
          _RoomItemCard(
            key: ValueKey(room.id),
            room: room,
            onEdit: () => onEdit(index),
            onAvailability: () => onAvailability(index),
          ),
      ],
    );
  }
}

class _RoomItemCard extends StatelessWidget {
  const _RoomItemCard({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onAvailability,
  });

  final RoomResponse room;
  final VoidCallback onEdit;
  final VoidCallback onAvailability;

  String get _roomName {
    final number = room.roomNumber;
    return number.toLowerCase().startsWith('room') ? number : 'Room ${number.trim()}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final muted = colors.onSurface.withValues(alpha: 0.5);
    final isSeatAvailable = room.availableSeats > 0;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.sm,
          children: [
            Row(
              spacing: Space.sm,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RoomImage(fileKey: room.images.firstOrNull, semanticLabel: room.roomNumber),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(Space.xs),
                            padding: const EdgeInsets.all(Space.xs),
                            decoration: BoxDecoration(
                              color: const Color(0xFF444444).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${room.roomWidth} x ${room.roomHeight} ft',
                              style: typos.labelSmall?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _roomName,
                                      style: typos.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: Space.xs),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Row(
                                        spacing: Space.xs,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              room.type.name,
                                              style: typos.labelSmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSeatAvailable) ...[
                                            const _Dot(),
                                            Flexible(
                                              child: Text(
                                                '${room.availableSeats} seat',
                                                style: typos.labelSmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Space.sm,
                                  vertical: Space.xs,
                                ),
                                decoration: ShapeDecoration(
                                  color: isSeatAvailable
                                      ? colors.primaryContainer
                                      : colors.secondaryContainer,
                                  shape: const StadiumBorder(),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: Space.xs,
                                  children: [
                                    _Dot(
                                      size: 6,
                                      color: isSeatAvailable ? colors.primary : colors.error,
                                    ),
                                    Text(
                                      isSeatAvailable ? 'Available' : 'Full',
                                      style: typos.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // rent & deposit
                          Row(
                            spacing: Space.xs,
                            children: [
                              Text(
                                room.rent.toMoney(),
                                style: typos.headlineMedium?.copyWith(color: colors.primary),
                              ),
                              Text(
                                '/ mo',
                                style: typos.labelMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: muted,
                                ),
                              ),
                              const _Dot(),
                              Flexible(
                                child: Text(
                                  'Deposit: ${room.deposit.toMoney()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typos.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const AppDivider(),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Edit'),
                ),
                FilledButton.icon(
                  onPressed: onAvailability,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.5),
                    foregroundColor: colors.onSurface,
                  ),
                  icon: const Icon(Icons.event_seat_outlined, size: 20),
                  label: const Text('Availability'),
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
  const _Dot({this.size = 4, this.color = Colors.grey});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
