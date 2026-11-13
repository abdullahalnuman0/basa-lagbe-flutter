import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/preferences_manager.dart';
import 'package:messseat/domain/enums/theme_mode.dart';
import 'package:messseat/domain/model/user.dart';
import 'package:messseat/features/shared/settings/settings_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks.dart';

void main() {
  late PreferencesManager preferences;
  late MockSessionManager session;
  late SettingsViewModel vm;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = PreferencesManager(await SharedPreferences.getInstance());
    session = MockSessionManager();
    when(() => session.user).thenReturn(User(id: 4, fullName: 'Nusrat Jahan'));
    vm = SettingsViewModel(preferences, session);
  });

  tearDown(() => vm.dispose());

  test('starts with the defaults', () {
    final state = vm.state;
    expect(vm.themeMode, AppThemeMode.SYSTEM);
    expect(state.inAppNotificationEnable, isTrue);
    expect(state.soundEnabled, isTrue);
    expect(state.vibrationEnabled, isTrue);
    expect(vm.user?.fullName, 'Nusrat Jahan');
  });

  test('saves the theme mode and notifies', () async {
    var notified = 0;
    vm.addListener(() => notified++);

    await vm.setThemeMode(AppThemeMode.DARK);

    expect(vm.themeMode, AppThemeMode.DARK);
    expect(vm.state.themeMode, AppThemeMode.DARK);
    expect(preferences.themeMode, AppThemeMode.DARK);
    expect(notified, 1);
  });

  test('updates the in-app notification switches', () async {
    await vm.setInAppNoty(false);
    await vm.setInAppNotySound(false);
    await vm.setInAppNotyVibration(false);

    final state = vm.state;
    expect(state.inAppNotificationEnable, isFalse);
    expect(state.soundEnabled, isFalse);
    expect(state.vibrationEnabled, isFalse);
    expect(preferences.inAppNotification, isFalse);
  });

  test('stops listening after dispose', () async {
    final other = SettingsViewModel(preferences, session);
    var notified = 0;
    other.addListener(() => notified++);
    other.dispose();

    await preferences.setInAppNoty(false);

    expect(notified, 0);
  });
}
