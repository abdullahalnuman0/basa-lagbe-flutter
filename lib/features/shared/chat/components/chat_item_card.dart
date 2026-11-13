import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../core/presentation/components/user_avatar.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/functions.dart';
import '../../../../data/dto/chat/chat_dtos.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class ChatItemCard extends StatelessWidget {
  const ChatItemCard({super.key, required this.chat, required this.onChatClick});

  final ChatResponse chat;
  final VoidCallback onChatClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return SectionCard(
      contentPadding: EdgeInsets.zero,
      onClick: onChatClick,
      children: [
        Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Row(
            children: [
              UserAvatar(
                url: chat.otherUserAvatarUrl?.toImageUrl(),
                name: chat.otherUserName,
                size: 48,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: Space.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.otherUserName,
                              style: typos.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeAgo(chat.lastMessageAt),
                            style: typos.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Space.xs),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat.lastMessagePreview ?? 'New chat',
                                style: typos.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Space.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  '${chat.unreadCount}',
                                  style: typos.labelSmall?.copyWith(color: colors.onPrimary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
