import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/functions.dart';
import '../../../../data/dto/chat/chat_dtos.dart';
import '../../../../data/enums/enums.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.own,
  });

  final ChatMessageResponse message;
  final String timestamp;
  final bool own;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final attachment = message.attachmentUrl;
    final isImage =
        message.type == MessageType.IMAGE && attachment != null && attachment.trim().isNotEmpty;

    return Row(
      mainAxisAlignment: own ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Material(
            color: own ? colors.primary : colors.surfaceContainerHigh,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(own ? 18 : 4),
              bottomRight: Radius.circular(own ? 4 : 18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isImage)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Semantics(
                          label: 'Shared image',
                          image: true,
                          child: CachedNetworkImage(
                            imageUrl: attachment.toImageUrl(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      message.content ?? '[attachment]',
                      style: context.typos.bodyMedium?.copyWith(
                        color: own ? colors.onPrimary : colors.onSurface,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      timestamp,
                      style: context.typos.labelSmall?.copyWith(
                        color: own
                            ? colors.onPrimary.withValues(alpha: 0.7)
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
