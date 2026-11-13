import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/room_image.dart';

class PropertyImageSection extends StatefulWidget {
  const PropertyImageSection({super.key, required this.images});

  final List<String> images;

  @override
  State<PropertyImageSection> createState() => _PropertyImageSectionState();
}

class _PropertyImageSectionState extends State<PropertyImageSection> {
  int _currentImgIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  @override
  void didUpdateWidget(covariant PropertyImageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) _startSlideshow();
  }

  void _startSlideshow() {
    _timer?.cancel();
    if (widget.images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _currentImgIndex = (_currentImgIndex + 1) % widget.images.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final index = images.isEmpty ? 0 : _currentImgIndex % images.length;
    final image = images.isEmpty ? null : images[index];

    return SizedBox(
      width: double.infinity,
      height: 220,
      child: AnimatedSwitcher(
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
          key: ValueKey(index),
          fileKey: image,
          semanticLabel: image,
          width: double.infinity,
          height: 220,
        ),
      ),
    );
  }
}
