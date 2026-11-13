import '../../../domain/enums/theme_mode.dart';

class SettingPreferences {
  const SettingPreferences({
    this.themeMode = AppThemeMode.SYSTEM,
    this.inAppNotificationEnable = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  final AppThemeMode themeMode;
  final bool inAppNotificationEnable;
  final bool soundEnabled;
  final bool vibrationEnabled;
}
