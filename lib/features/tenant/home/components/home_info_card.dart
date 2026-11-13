import 'package:flutter/material.dart';

import '../../../../ui/theme/space.dart';

class CampusSafeSpaceCard extends StatelessWidget {
  const CampusSafeSpaceCard({super.key, required this.onSearch});

  final VoidCallback onSearch;

  static const _dark = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Space.xxxl, horizontal: Space.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF087265), Color(0xFF087265), Color(0xFF1E1E4D)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: const StadiumBorder(),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 16,
                  color: Color(0xFFFBBF24),
                  semanticLabel: 'Trending',
                ),
                SizedBox(width: Space.xxl),
                Flexible(
                  child: Text(
                    'HOSTELS, SUB-LETS, AND BACHELOR FLATS',
                    style: TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          const Text(
            'Find Your Perfect Safe\nSpace Near Campus',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 36 / 28,
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(
            'Compare verified boys & girls hostels, studio flats, and\n'
            'bachelor rooms with zero broker fees.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 22 / 14,
            ),
          ),
          const SizedBox(height: Space.xxl),
          FilledButton.icon(
            onPressed: onSearch,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _dark,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.search_outlined, size: 20, semanticLabel: 'Search'),
            label: const Text(
              'Explore Nearby Rooms',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
