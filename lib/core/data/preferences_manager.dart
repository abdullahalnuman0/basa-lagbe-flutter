import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/enums/enums.dart';
import '../../domain/enums/theme_mode.dart';

class PreferencesManager extends ChangeNotifier {
  PreferencesManager(this._prefs);

  static const _kTheme = 'theme_mode';
  static const _kInAppNoty = 'in_app_noty';
  static const _kInAppNotySound = 'in_app_noty_sound';
  static const _kInAppNotyVibration = 'in_app_noty_vibration';

  final SharedPreferences _prefs;

  AppThemeMode get themeMode =>
      enumByName(AppThemeMode.values, _prefs.getString(_kTheme), AppThemeMode.SYSTEM);

  bool get inAppNotification => _prefs.getBool(_kInAppNoty) ?? true;

  bool get inAppNotySound => _prefs.getBool(_kInAppNotySound) ?? true;

  bool get inAppNotyVibration => _prefs.getBool(_kInAppNotyVibration) ?? true;

  //============= Set =================

  Future<void> setThemeMode(AppThemeMode mode) =>
      _write(() => _prefs.setString(_kTheme, mode.name));

  Future<void> setInAppNoty(bool v) => _write(() => _prefs.setBool(_kInAppNoty, v));

  Future<void> setInAppNotySound(bool v) => _write(() => _prefs.setBool(_kInAppNotySound, v));

  Future<void> setInAppNotyVibration(bool v) =>
      _write(() => _prefs.setBool(_kInAppNotyVibration, v));

  Future<void> _write(Future<bool> Function() block) async {
    await block();
    notifyListeners();
  }
}
