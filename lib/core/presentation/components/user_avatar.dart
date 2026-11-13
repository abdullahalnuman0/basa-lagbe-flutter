import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../ui/theme/theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.url, required this.name, this.size = 40});

  final String? url;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
      child: Text(
        initials(name),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: size / 2.6,
        ),
      ),
    );
    if (url == null || url!.trim().isEmpty) return fallback;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: colors.surfaceContainerHigh,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => fallback,
        ),
      ),
    );
  }
}

String initials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(' ').where((p) => p.trim().isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  String take(String s, int n) => s.length <= n ? s : s.substring(0, n);
  if (parts.length == 1) return take(parts[0], 2).toUpperCase();
  return (take(parts.first, 1) + take(parts.last, 1)).toUpperCase();
}
