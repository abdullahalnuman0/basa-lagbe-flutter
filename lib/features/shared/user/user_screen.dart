import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/components/user_avatar.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/utils/functions.dart';
import '../../../data/enums/enums.dart';
import '../../../domain/model/user.dart';
import '../../../main_view_model.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();
    final user = main.user;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'User profile',
            onBack: context.pop,
            actions: [
              IconButton(
                tooltip: 'UpdateProfile',
                onPressed: () => AppSnackbar.showWithAction(
                  "This feature might or might not arrive, so enjoy the app's other features.",
                ),
                icon: const Opacity(opacity: 0.6, child: Icon(Icons.mode_edit_outline_outlined)),
              ),
            ],
          ),
          if (user != null)
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ProfileCard(user: user, loggedOut: main.loggedOut),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.user, required this.loggedOut});

  final User user;
  final VoidCallback loggedOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final location = [user.area, user.district, user.division].whereType<String>().join(', ');
    final roles = user.roles.map((r) => _capitalize(r.name)).join(', ');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(url: user.avatarUrl?.toImageUrl(), name: user.fullName, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: context.typos.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: context.typos.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: user.status == UserStatus.ACTIVE
                      ? colors.primaryContainer
                      : colors.errorContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    _capitalize(user.status.name),
                    style: context.typos.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Column(
            spacing: 14,
            children: [
              _UserInfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
              _UserInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone.trim().isEmpty ? 'Not provided' : user.phone,
              ),
              _UserInfoRow(
                icon: Icons.person_outline,
                label: 'Gender',
                value: _capitalize(user.gender.name),
              ),
              _UserInfoRow(
                icon: Icons.school_outlined,
                label: 'Institution',
                value: user.institution ?? 'Not provided',
              ),
              _UserInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: location.trim().isEmpty ? 'Not provided' : location,
              ),
              _UserInfoRow(
                icon: Icons.badge_outlined,
                label: 'Roles',
                value: roles.trim().isEmpty ? 'User' : roles,
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: loggedOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
            ),
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  const _UserInfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 22, color: colors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.typos.labelMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
              Text(value, style: context.typos.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

String _capitalize(String value) {
  final lower = value.toLowerCase();
  return lower.isEmpty ? lower : lower[0].toUpperCase() + lower.substring(1);
}
