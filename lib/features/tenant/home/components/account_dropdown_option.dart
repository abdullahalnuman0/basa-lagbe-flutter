import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/components/app_dropdown_menu.dart';
import '../../../../core/presentation/components/user_avatar.dart';
import '../../../../core/utils/functions.dart';
import '../../../../domain/model/user.dart';
import '../../../../main_view_model.dart';
import '../../../../ui/theme/theme.dart';

class AccountDropdownOption extends StatelessWidget {
  const AccountDropdownOption({
    super.key,
    required this.user,
    this.size = 40,
    required this.onProfile,
    this.onNotification,
    this.onSaved,
    required this.loggedOut,
  });

  final User? user;
  final double size;
  final VoidCallback onProfile;
  final VoidCallback? onNotification;
  final VoidCallback? onSaved;
  final VoidCallback loggedOut;

  @override
  Widget build(BuildContext context) {
    final unreadNoty = context.select<MainViewModel, int>((vm) => vm.unreadNotification);
    final typos = context.typos;

    return AppDropdownMenu(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(user?.fullName ?? '—', style: typos.titleSmall, maxLines: 1),
          Text(
            user?.email ?? '',
            style: typos.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            maxLines: 1,
          ),
        ],
      ),
      entries: [
        DropdownEntry(label: 'Profile', icon: Icons.person, onClick: onProfile),
        if (onNotification != null)
          DropdownEntry(
            label: 'Notifications',
            icon: Icons.notifications,
            onClick: onNotification!,
            badged: unreadNoty,
          ),
        if (onSaved != null)
          DropdownEntry(label: 'Saved posts', icon: Icons.bookmark, onClick: onSaved!),
        DropdownEntry(label: 'Log out', icon: Icons.logout, destructive: true, onClick: loggedOut),
      ],
      anchorBuilder: (context, toggle) => Badge(
        isLabelVisible: unreadNoty > 0,
        label: Text('$unreadNoty'),
        child: IconButton(
          onPressed: toggle,
          padding: EdgeInsets.zero,
          icon: UserAvatar(url: user?.avatarUrl?.toImageUrl(), name: user?.fullName, size: size),
        ),
      ),
    );
  }
}
