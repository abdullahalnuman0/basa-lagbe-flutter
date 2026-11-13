import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/enums/enums.dart';
import '../../../domain/enums/property_gender.dart';
import '../../../domain/enums/property_type.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import '../../utils/functions.dart';
import '../components/listing_item_clip.dart';
import '../components/room_image.dart';
import '../components/section_card.dart';

class RoomItemCard extends StatefulWidget {
  const RoomItemCard({
    super.key,
    required this.isOwnerView,
    required this.images,
    required this.roomNumber,
    required this.propertyType,
    required this.gender,
    required this.roomType,
    required this.rent,
    required this.location,
    required this.approved,
    required this.title,
    required this.institutionNearby,
    required this.roomSize,
    required this.totalSeats,
    this.totalView = 0,
    this.moreContent,
    this.onClick,
  });

  final bool isOwnerView;
  final List<String> images;
  final String roomNumber;
  final PropertyType propertyType;
  final PropertyGender gender;
  final RoomType roomType;
  final int rent;
  final String location;
  final bool approved;
  final String title;
  final String institutionNearby;
  final String roomSize;
  final int totalSeats;
  final int totalView;
  final Widget? moreContent;
  final VoidCallback? onClick;

  @override
  State<RoomItemCard> createState() => _RoomItemCardState();
}

class _RoomItemCardState extends State<RoomItemCard> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  @override
  void didUpdateWidget(covariant RoomItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _index = 0;
      _startSlideshow();
    }
  }

  void _startSlideshow() {
    _timer?.cancel();
    if (widget.images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _index = (_index + 1) % widget.images.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final images = widget.images;
    final image = images.isEmpty ? null : images[_index.clamp(0, images.length - 1)];
    final perUnit = const [PropertyType.MESS, PropertyType.HOSTEL].contains(widget.propertyType)
        ? 'seat'
        : 'month';
    final divider = colors.onSurface.withValues(alpha: 0.2);

    return SectionCard(
      contentPadding: EdgeInsets.zero,
      onClick: widget.onClick,
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image  smooth transition
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
                  key: ValueKey(image),
                  fileKey: image,
                  semanticLabel: widget.title,
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
                      child: Wrap(
                        spacing: Space.xs,
                        runSpacing: Space.xs,
                        children: [
                          ListingItemClip(label: widget.propertyType.name, icon: Icons.hotel),
                          ListingItemClip(
                            label: widget.roomType.name,
                            bg: colors.secondary,
                            onBg: colors.onSecondary,
                          ),
                          ListingItemClip(
                            label: widget.gender.name,
                            bg: colors.tertiary,
                            onBg: colors.onTertiary,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Colors.white,
                            semanticLabel: 'location',
                          ),
                          const SizedBox(width: Space.xs),
                          Expanded(
                            child: Text(
                              widget.location,
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
              Positioned(
                top: Space.md,
                right: Space.md,
                child: ListingItemClip(
                  label: '${widget.rent.toMoney()}/$perUnit',
                  bg: Colors.white,
                  onBg: colors.primary,
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
              if (widget.isOwnerView && !widget.approved) ...[
                const PendingAlert(),
                const SizedBox(height: Space.sm),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: widget.title,
                        children: [
                          TextSpan(
                            text: '(${widget.roomNumber})',
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.7),
                              fontSize: typos.bodyMedium?.fontSize,
                            ),
                          ),
                        ],
                      ),
                      style: typos.headlineSmall,
                    ),
                  ),
                  if (widget.isOwnerView)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: Space.xs),
                          Text(
                            '${widget.totalView}',
                            style: typos.bodyMedium?.copyWith(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.xs),
              if (widget.institutionNearby.length > 3)
                Row(
                  children: [
                    Icon(Icons.school_outlined, size: 16, color: colors.primary),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Text(
                        widget.institutionNearby,
                        style: typos.labelMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: Space.sm),
              Divider(height: 1, color: divider),
              const SizedBox(height: Space.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _Meta(icon: Icons.straighten_outlined, text: '${widget.roomSize} ft'),
                  ),
                  SizedBox(height: 12, child: VerticalDivider(width: 1, color: divider)),
                  Flexible(
                    child: _Meta(
                      icon: Icons.hotel_outlined,
                      text: '${widget.totalSeats} Available Seats',
                    ),
                  ),
                ],
              ),
              if (widget.moreContent != null) ...[
                const SizedBox(height: Space.sm),
                widget.moreContent!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: Space.xs),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typos.labelMedium,
          ),
        ),
      ],
    );
  }
}
