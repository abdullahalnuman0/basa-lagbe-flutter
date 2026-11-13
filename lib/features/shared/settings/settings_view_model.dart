import 'package:flutter/foundation.dart';

import '../../../core/data/preferences_manager.dart';
import '../../../core/data/session_manager.dart';
import '../../../domain/enums/theme_mode.dart';
import '../../../domain/model/user.dart';
import 'setting_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._preferences, this._session) {
    _preferences.addListener(notifyListeners);
    _session.addListener(notifyListeners);
  }

  final PreferencesManager _preferences;
  final SessionManager _session;

  AppThemeMode get themeMode => _preferences.themeMode;

  User? get user => _session.user;

  SettingPreferences get state => SettingPreferences(
    themeMode: _preferences.themeMode,
    inAppNotificationEnable: _preferences.inAppNotification,
    soundEnabled: _preferences.inAppNotySound,
    vibrationEnabled: _preferences.inAppNotyVibration,
  );

  Future<void> setThemeMode(AppThemeMode mode) => _preferences.setThemeMode(mode);

  Future<void> setInAppNoty(bool value) => _preferences.setInAppNoty(value);

  Future<void> setInAppNotySound(bool value) => _preferences.setInAppNotySound(value);

  Future<void> setInAppNotyVibration(bool value) => _preferences.setInAppNotyVibration(value);

  @override
  void dispose() {
    _preferences.removeListener(notifyListeners);
    _session.removeListener(notifyListeners);
    super.dispose();
  }
}
