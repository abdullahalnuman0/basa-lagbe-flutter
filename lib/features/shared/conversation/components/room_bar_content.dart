import 'package:flutter/material.dart';

import '../../../../core/presentation/components/room_image.dart';
import '../../../../core/presentation/components/section_card.dart';
import '../../../../core/utils/functions.dart';
import '../../../../data/dto/tenant/tenant_dtos.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class RoomBarContent extends StatelessWidget {
  const RoomBarContent({super.key, required this.room, required this.onClick});

  final RoomTenantResponse room;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final meta = context.typos.labelMedium?.copyWith(
      color: context.colors.onSurface.withValues(alpha: 0.7),
    );

    return Padding(
      padding: const EdgeInsets.only(left: Space.sm, right: Space.sm, top: Space.sm),
      child: SectionCard(
        contentPadding: EdgeInsets.zero,
        onClick: onClick,
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              spacing: Space.sm,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RoomImage(
                    fileKey: room.images.firstOrNull,
                    width: 56,
                    height: 56,
                    semanticLabel: room.title,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.title,
                        style: context.typos.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(room.roomNumber, style: meta)),
                          Text(room.rent.toMoney(), style: meta),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
