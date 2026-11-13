import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/favorites_manager.dart';
import 'package:messseat/core/data/preferences_manager.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/domain/enums/theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SessionManager', () {
    test('persists the session across instances', () async {
      final prefs = await SharedPreferences.getInstance();
      final session = SessionManager(prefs);
      expect(session.isLoggedIn, isFalse);

      await session.saveSession(
        const AuthResponse(
          accessToken: 'access',
          refreshToken: 'refresh',
          user: UserResponse(id: 4, fullName: 'Nadia', roles: ['OWNER']),
        ),
      );

      final restored = SessionManager(prefs);
      expect(restored.isLoggedIn, isTrue);
      expect(restored.accessToken(), 'access');
      expect(restored.refreshToken(), 'refresh');
      expect(restored.user?.fullName, 'Nadia');
      expect(restored.user?.isOwner, isTrue);
    });

    test('notifies listeners on login and logout', () async {
      final session = SessionManager(await SharedPreferences.getInstance());
      var calls = 0;
      session.addListener(() => calls++);

      await session.saveSession(const AuthResponse(accessToken: 'a', refreshToken: 'r'));
      await session.clear();
      await session.clear();

      expect(calls, 2);
      expect(session.accessToken(), isNull);
      expect(session.user, isNull);
    });

    test('ignores a corrupt stored user', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'a', 'user_json': '{not json'});
      final session = SessionManager(await SharedPreferences.getInstance());
      expect(session.isLoggedIn, isTrue);
      expect(session.user, isNull);
    });
  });

  group('PreferencesManager', () {
    test('has sensible defaults', () async {
      final prefs = PreferencesManager(await SharedPreferences.getInstance());
      expect(prefs.themeMode, AppThemeMode.SYSTEM);
      expect(prefs.inAppNotification, isTrue);
      expect(prefs.inAppNotySound, isTrue);
      expect(prefs.inAppNotyVibration, isTrue);
    });

    test('stores changes', () async {
      final prefs = PreferencesManager(await SharedPreferences.getInstance());
      await prefs.setThemeMode(AppThemeMode.DARK);
      await prefs.setInAppNoty(false);
      await prefs.setInAppNotySound(false);
      await prefs.setInAppNotyVibration(false);

      final again = PreferencesManager(await SharedPreferences.getInstance());
      expect(again.themeMode, AppThemeMode.DARK);
      expect(again.inAppNotification, isFalse);
      expect(again.inAppNotySound, isFalse);
      expect(again.inAppNotyVibration, isFalse);
    });

    test('treats an unknown theme as system', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'PURPLE'});
      final prefs = PreferencesManager(await SharedPreferences.getInstance());
      expect(prefs.themeMode, AppThemeMode.SYSTEM);
    });
  });

  test('FavoritesManager adds and removes ids', () async {
    final favorites = FavoritesManager(await SharedPreferences.getInstance());
    await favorites.addFavorite(10);
    await favorites.addFavorite(11);
    await favorites.addFavorite(10);
    expect(favorites.favoritePostIds, {'10', '11'});
    expect(favorites.isFavorite(10), isTrue);

    await favorites.removeFavorite(10);
    expect(favorites.isFavorite(10), isFalse);
    expect(favorites.favoritePostIds, {'11'});
  });
}
