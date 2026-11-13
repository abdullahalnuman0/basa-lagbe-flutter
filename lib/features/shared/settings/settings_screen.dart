import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../main_view_model.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import 'components/account_info_section.dart';
import 'components/appearance_section.dart';
import 'components/header_section.dart';
import 'components/notification_section.dart';
import 'settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(locator(), locator()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final main = context.watch<MainViewModel>();
    final user = vm.user;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.xxl),
      children: [
        const HeaderSection(),
        if (user != null) ...[
          const SizedBox(height: Space.md),
          AccountInfoSection(usr: user, onClick: () => context.push(Routes.user)),
        ],
        const SizedBox(height: Space.md),
        AppearanceSection(selectedTheme: vm.themeMode, onThemeMode: vm.setThemeMode),
        const SizedBox(height: Space.md),
        NotificationSection(
          state: vm.state,
          notificationsAllowed: main.notificationAllowed,
          onInAppNoty: vm.setInAppNoty,
          onSound: vm.setInAppNotySound,
          onVibration: vm.setInAppNotyVibration,
          onRequestNotifications: main.requestNotifications,
        ),
      ],
    );
  }
}
