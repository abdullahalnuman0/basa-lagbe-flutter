import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_card.dart';
import '../../../../core/presentation/components/listing_item_clip.dart';
import '../../../../core/presentation/components/room_image.dart';
import '../../../../core/utils/functions.dart';
import '../../../../data/dto/property/property_dtos.dart';
import '../../../../data/dto/room/room_dtos.dart';
import '../../../../domain/enums/property_type.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class ListingItem extends StatefulWidget {
  const ListingItem({super.key, required this.property, this.moreContent, this.rooms});

  final PropertyResponse property;
  final Widget? moreContent;
  final List<RoomResponse>? rooms;

  @override
  State<ListingItem> createState() => _ListingItemState();
}

class _ListingItemState extends State<ListingItem> {
  int _currentRoomIndex = 0;
  Timer? _timer;

  List<RoomResponse> get _rooms => widget.rooms ?? widget.property.rooms;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  @override
  void didUpdateWidget(covariant ListingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRooms = oldWidget.rooms ?? oldWidget.property.rooms;
    if (oldRooms.length != _rooms.length) {
      _currentRoomIndex = 0;
      _startRotation();
    }
  }

  void _startRotation() {
    _timer?.cancel();
    if (_rooms.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _currentRoomIndex = (_currentRoomIndex + 1) % _rooms.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _rooms;
    if (rooms.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final typos = context.typos;
    final property = widget.property;
    final room = rooms[_currentRoomIndex % rooms.length];
    final perUnit = const [PropertyType.MESS, PropertyType.HOSTEL].contains(property.type)
        ? 'seat'
        : 'month';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // image + rent smooth transition
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  reverseDuration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.25, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: RoomImage(
                    key: ValueKey(room.id),
                    fileKey: room.images.firstOrNull,
                    semanticLabel: room.roomNumber,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Space.md),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Space.xs,
                          children: [
                            ListingItemClip(label: property.type.name, icon: Icons.hotel),
                            ListingItemClip(
                              label: property.gender.name,
                              bg: colors.tertiary,
                              onBg: colors.onTertiary,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 300),
                          child: ListingItemClip(
                            key: ValueKey(room.rent),
                            label: '${room.rent.toMoney()}/$perUnit',
                            bg: Colors.white,
                            onBg: colors.primary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          spacing: Space.xs,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: Colors.white,
                              semanticLabel: 'location',
                            ),
                            Expanded(
                              child: Text(
                                '${property.area}, ${property.district}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typos.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!property.approved) ...[const PendingAlert(), const SizedBox(height: Space.sm)],
                Text(property.title, style: typos.headlineSmall),
                const SizedBox(height: Space.xs),
                Row(
                  spacing: Space.xs,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 16,
                      color: colors.primary,
                      semanticLabel: 'institution',
                    ),
                    Expanded(
                      child: Text(
                        property.institutionNearby,
                        style: typos.labelMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.sm),
                const AppDivider(),
                const SizedBox(height: Space.sm),
                AvailableValueCard(
                  rooms: rooms.length,
                  seats: rooms.fold(0, (sum, r) => sum + r.availableSeats),
                ),
                if (widget.moreContent != null) ...[
                  const SizedBox(height: Space.sm),
                  widget.moreContent!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListingItemBtns extends StatelessWidget {
  const ListingItemBtns({super.key, required this.onEdit, required this.onView});

  final VoidCallback onEdit;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Space.md,
      children: [
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Listing'),
        ),
        Expanded(
          child: FilledButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.remove_red_eye_outlined),
            label: const Text('View Details'),
          ),
        ),
      ],
    );
  }
}

class AvailableValueCard extends StatelessWidget {
  const AvailableValueCard({super.key, required this.rooms, required this.seats});

  final int rooms;
  final int seats;

  @override
  Widget build(BuildContext context) {
    final style = context.typos.labelMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Space.xs,
          children: [
            const Icon(Icons.meeting_room, size: 16, semanticLabel: 'Rooms'),
            Text('$rooms Rooms', style: style),
          ],
        ),
        SizedBox(
          height: 12,
          child: VerticalDivider(width: 1, color: context.colors.outlineVariant),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Space.xs,
          children: [
            const Icon(Icons.hotel, size: 16, semanticLabel: 'Seats'),
            Text('$seats Available Seats', style: style),
          ],
        ),
      ],
    );
  }
}
