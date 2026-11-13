import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../ui/theme/theme.dart';
import '../setting_preferences.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.state,
    required this.notificationsAllowed,
    required this.onInAppNoty,
    required this.onSound,
    required this.onVibration,
    required this.onRequestNotifications,
  });

  final SettingPreferences state;
  final bool notificationsAllowed;
  final ValueChanged<bool> onInAppNoty;
  final ValueChanged<bool> onSound;
  final ValueChanged<bool> onVibration;
  final VoidCallback onRequestNotifications;

  @override
  Widget build(BuildContext context) {
    final ext = context.appColors;
    final allowed = state.inAppNotificationEnable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Notifications'),
        const SizedBox(height: 4),
        SectionCard(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (!notificationsAllowed)
              ActionRow(
                title: 'Enable Notifications',
                subtitle: 'Allow notifications to receive important updates',
                icon: Icons.notifications_off_rounded,
                tint: ext.danger,
                onClick: onRequestNotifications,
                trailing: const _Chevron(),
              ),
            SwitchRow(
              title: 'In-App Notifications',
              checked: state.inAppNotificationEnable,
              onCheckedChange: onInAppNoty,
              subtitle: 'Get notified while using the app',
              icon: Icons.notifications_active_rounded,
              iconTint: ext.danger,
            ),
            SwitchRow(
              title: 'Sound',
              checked: state.soundEnabled,
              onCheckedChange: onSound,
              icon: Icons.volume_up_rounded,
              iconTint: ext.accent,
              enabled: allowed,
            ),
            SwitchRow(
              title: 'Vibration',
              checked: state.vibrationEnabled,
              onCheckedChange: onVibration,
              icon: Icons.vibration_rounded,
              iconTint: ext.accent,
              enabled: allowed,
            ),
          ],
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.keyboard_arrow_right_rounded, color: context.colors.onSurfaceVariant);
  }
}

class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.tint, this.size = 40});

  final IconData icon;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: tint, size: size * 0.5),
    );
  }
}

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.checked,
    required this.onCheckedChange,
    this.subtitle,
    this.icon,
    this.iconTint,
    this.enabled = true,
  });

  final String title;
  final bool checked;
  final ValueChanged<bool> onCheckedChange;
  final String? subtitle;
  final IconData? icon;
  final Color? iconTint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => onCheckedChange(!checked) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 14,
          children: [
            if (icon != null)
              IconTile(
                icon: icon!,
                tint: enabled ? iconTint ?? colors.primary : colors.onSurfaceVariant,
                size: 36,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typos.titleSmall?.copyWith(
                      color: enabled ? colors.onSurface : colors.onSurfaceVariant,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: context.typos.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Switch(
              value: checked,
              onChanged: enabled ? onCheckedChange : null,
              activeTrackColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onClick,
    this.subtitle,
    this.tint,
    this.titleColor,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final VoidCallback onClick;
  final String? subtitle;
  final Color? tint;
  final Color? titleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 14,
          children: [
            IconTile(icon: icon, tint: tint ?? colors.primary, size: 36),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typos.titleSmall?.copyWith(
                      color: titleColor ?? colors.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: context.typos.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
