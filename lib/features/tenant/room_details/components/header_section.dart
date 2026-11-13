import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/listing_item_clip.dart';
import '../../../../core/presentation/components/room_image.dart';
import '../../../../core/utils/functions.dart';
import '../../../../data/enums/enums.dart';
import '../../../../domain/enums/property_gender.dart';
import '../../../../domain/enums/property_type.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import 'glass_icon_button.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({
    super.key,
    required this.images,
    this.isSaved = false,
    required this.propertyType,
    required this.gender,
    required this.roomType,
    required this.rent,
    required this.onFavorite,
  });

  final List<String> images;
  final bool isSaved;
  final PropertyType propertyType;
  final PropertyGender gender;
  final RoomType roomType;
  final int rent;
  final VoidCallback onFavorite;

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  int _currentRoomIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  @override
  void didUpdateWidget(covariant HeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _currentRoomIndex = 0;
      _startSlideshow();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSlideshow() {
    _timer?.cancel();
    if (widget.images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() => _currentRoomIndex = (_currentRoomIndex + 1) % widget.images.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final images = widget.images;
    final image = images.isEmpty
        ? null
        : images.length <= 1
        ? images[0]
        : images[_currentRoomIndex.clamp(0, images.length - 1)];
    final perUnit = const [PropertyType.MESS, PropertyType.HOSTEL].contains(widget.propertyType)
        ? 'seat'
        : 'month';

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Smooth image transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            reverseDuration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.25, 0), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: RoomImage(
              key: ValueKey(image),
              fileKey: image,
              semanticLabel: image,
              width: double.infinity,
              height: 200,
            ),
          ),

          // Save button
          Positioned(
            top: Space.xs,
            right: Space.xs,
            child: GlassIconButton(
              icon: widget.isSaved ? Icons.favorite : Icons.favorite_border,
              semanticLabel: widget.isSaved ? 'Remove post' : 'Save post',
              onPressed: widget.onFavorite,
            ),
          ),

          // Room info
          Positioned(
            left: Space.sm,
            bottom: Space.sm,
            child: Row(
              spacing: Space.xs,
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

          Positioned(
            right: Space.sm,
            bottom: Space.sm,
            child: ListingItemClip(
              label: '${widget.rent.toMoney()}/$perUnit',
              bg: Colors.white,
              onBg: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
