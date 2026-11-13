import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/preferences_manager.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/core/push/push_service.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/dto/notification/notification_response.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/data/repository/notification_repository.dart';
import 'package:messseat/data/repository/unread_count_repository.dart';
import 'package:messseat/data/repository/user_repository.dart';
import 'package:messseat/main_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockUnreadCountRepository extends Mock implements UnreadCountRepository {}

class MockPushService extends Mock implements PushService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserRepository userRepo;
  late MockNotificationRepository notyRepo;
  late MockUnreadCountRepository unreadRepo;
  late SessionManager session;
  late PreferencesManager preferences;
  late StreamController<NotificationResponse> live;
  late MainViewModel vm;

  const channel = MethodChannel('dev.example.messseat/notification');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    session = SessionManager(prefs);
    preferences = PreferencesManager(prefs);
    userRepo = MockUserRepository();
    notyRepo = MockNotificationRepository();
    unreadRepo = MockUnreadCountRepository();
    live = StreamController<NotificationResponse>.broadcast();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => call.method == 'canPostNotifications' ? true : null,
    );

    when(() => userRepo.heartbeat()).thenAnswer((_) async {});
    when(() => notyRepo.liveMessage(any())).thenAnswer((_) => live.stream);
    when(() => notyRepo.markNotificationRead(any())).thenAnswer((_) async {});
    when(() => unreadRepo.updateChatCount()).thenAnswer((_) async {});
    when(() => unreadRepo.updateNotificationCount()).thenAnswer((_) async {});
    when(() => unreadRepo.unreadChatCount).thenReturn(0);
    when(() => unreadRepo.unreadNotificationCount).thenReturn(0);

    vm = MainViewModel(
      userRepo: userRepo,
      unreadRepo: unreadRepo,
      notyRepo: notyRepo,
      preferences: preferences,
      session: session,
      push: MockPushService(),
    );
  });

  tearDown(() {
    vm.dispose();
    live.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  Future<void> login() => session.saveSession(
    const AuthResponse(
      accessToken: 'a',
      refreshToken: 'r',
      user: UserResponse(id: 77, roles: ['TENANT']),
    ),
  );

  NotificationResponse noty(int id, {bool read = false}) =>
      NotificationResponse(id: id, title: 'New message', read: read);

  test('logged out user has no live subscription or heartbeat', () {
    expect(vm.isLoggedIn, isFalse);
    verifyNever(() => notyRepo.liveMessage(any()));
    verifyNever(() => userRepo.heartbeat());
  });

  test('logging in starts the heartbeat, counts and live notifications', () async {
    await login();

    expect(vm.isLoggedIn, isTrue);
    expect(vm.user?.id, 77);
    verify(() => userRepo.heartbeat()).called(1);
    verify(() => unreadRepo.updateChatCount()).called(1);
    verify(() => unreadRepo.updateNotificationCount()).called(1);
    verify(() => notyRepo.liveMessage(77)).called(1);
  });

  test('an incoming notification shows the banner once', () async {
    await login();

    live.add(noty(1));
    live.add(noty(1));
    await pumpEventQueue();

    expect(vm.banner?.id, 1);
    verify(() => unreadRepo.incrementUnreadNotyCount()).called(1);
  });

  test('read or suppressed notifications are ignored', () async {
    await login();

    vm.onIncoming(noty(2, read: true));
    vm.setBannerSuppressed(true);
    vm.onIncoming(noty(3));

    expect(vm.banner, isNull);
    verifyNever(() => unreadRepo.incrementUnreadNotyCount());
  });

  test('in-app banners can be switched off but the count still moves', () async {
    await preferences.setInAppNoty(false);
    await login();

    vm.onIncoming(noty(4));

    expect(vm.banner, isNull);
    verify(() => unreadRepo.incrementUnreadNotyCount()).called(1);
  });

  test('a late dismiss does not hide a newer banner', () async {
    await login();
    vm.onIncoming(noty(5));
    vm.onIncoming(noty(6));

    vm.dismissBanner(5);
    expect(vm.banner?.id, 6);

    vm.dismissBanner(6);
    expect(vm.banner, isNull);
  });

  test('clicking the banner marks it read', () async {
    await login();
    vm.onIncoming(noty(8));

    await vm.onBannerClick(noty(8));

    expect(vm.banner, isNull);
    verify(() => notyRepo.markNotificationRead(8)).called(1);
    verify(() => unreadRepo.decrementUnreadNotyCount()).called(1);
  });

  test('logout clears the banner', () async {
    await login();
    vm.onIncoming(noty(9));

    await vm.loggedOut();

    expect(vm.isLoggedIn, isFalse);
    expect(vm.banner, isNull);
  });

  test('notification permission status comes from the platform', () async {
    expect(vm.notificationAllowed, isFalse);
    await vm.refreshNotificationStatus();
    expect(vm.notificationAllowed, isTrue);
  });

  test('theme mode follows the preferences', () async {
    var notified = 0;
    vm.addListener(() => notified++);
    await preferences.setThemeMode(preferences.themeMode);
    expect(notified, greaterThan(0));
  });
}
