import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/repository/file_repository.dart';
import '../../utils/functions.dart';

/// Server image by file key, falling back to the bundled room picture while loading or on error.
class RoomImage extends StatelessWidget {
  const RoomImage({
    super.key,
    required this.fileKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String? fileKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      FileRepository.roomDefaultImage,
      fit: fit,
      width: width,
      height: height,
    );
    if (fileKey == null || fileKey!.isEmpty) return fallback;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: CachedNetworkImage(
        imageUrl: fileKey!.toImageUrl(),
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
