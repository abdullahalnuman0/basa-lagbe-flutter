import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../core/presentation/components/user_avatar.dart';
import '../../../../core/utils/functions.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class OwnerInfoCard extends StatelessWidget {
  const OwnerInfoCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isChatOpening,
    required this.onCall,
    required this.onChat,
  });

  final String name;
  final String? avatarUrl;
  final bool isChatOpening;
  final VoidCallback onCall;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return SectionCard(
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xxl),
          child: Row(
            spacing: Space.md,
            children: [
              UserAvatar(url: avatarUrl?.toImageUrl(), name: name, size: 48),
              Expanded(child: Text(name, style: context.typos.headlineMedium)),
              FilledButton(
                onPressed: onCall,
                style: FilledButton.styleFrom(
                  shape: buttonShape,
                  padding: const EdgeInsets.symmetric(vertical: Space.md),
                  minimumSize: const Size(58, 40),
                  backgroundColor: const Color(0xFF444444),
                  foregroundColor: Colors.white,
                ),
                child: const Icon(Icons.call_outlined, semanticLabel: 'Call'),
              ),
              FilledButton(
                onPressed: onChat,
                style: FilledButton.styleFrom(
                  shape: buttonShape,
                  padding: const EdgeInsets.all(Space.md),
                  foregroundColor: Colors.white,
                ),
                child: isChatOpening
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Space.xs,
                        children: [
                          Icon(Icons.chat_bubble_outline, semanticLabel: 'Chat'),
                          Text('Chat'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
