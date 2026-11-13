import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../core/presentation/components/user_avatar.dart';
import '../../../../core/utils/functions.dart';
import '../../../../domain/model/user.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class AccountInfoSection extends StatelessWidget {
  const AccountInfoSection({super.key, required this.usr, required this.onClick});

  final User usr;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Account'),
        const SizedBox(height: Space.xs),
        SectionCard(
          onClick: onClick,
          children: [
            Row(
              children: [
                UserAvatar(url: usr.avatarUrl?.toImageUrl(), name: usr.fullName, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usr.fullName,
                        style: context.typos.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usr.email,
                        style: context.typos.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Opacity(
                  opacity: 0.5,
                  child: Icon(Icons.arrow_forward_ios_outlined, size: 16, semanticLabel: 'Forward'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
