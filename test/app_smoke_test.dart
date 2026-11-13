import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:messseat/app.dart';
import 'package:messseat/core/data/favorites_manager.dart';
import 'package:messseat/core/data/preferences_manager.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/push/push_service.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/data/dto/notification/notification_response.dart';
import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/dto/room/room_dtos.dart';
import 'package:messseat/data/dto/tenant/tenant_dtos.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/data/repository/auth_repository.dart';
import 'package:messseat/data/repository/chat_repository.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/data/repository/notification_repository.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/data/repository/tenant_repository.dart';
import 'package:messseat/data/repository/unread_count_repository.dart';
import 'package:messseat/data/repository/user_repository.dart';
import 'package:messseat/domain/enums/property_gender.dart';
import 'package:messseat/domain/enums/property_type.dart';
import 'package:messseat/main_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockFileRepository extends Mock implements FileRepository {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockPropertyRepository extends Mock implements PropertyRepository {}

class MockTenantRepository extends Mock implements TenantRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockPushService extends Mock implements PushService {}

final _createdAt = DateTime.utc(2026, 1, 5, 10);

RoomResponse _room(int id) => RoomResponse(
  totalViews: 31,
  availableSeats: 2,
  deposit: 2000,
  id: id,
  images: const [],
  rent: 4500,
  roomHeight: 10,
  roomNumber: 'A-$id',
  roomWidth: 12,
  type: RoomType.DOUBLE,
  createdAt: _createdAt,
);

PropertyResponse _property(int id, {bool approved = true}) => PropertyResponse(
  totalViews: 120,
  id: id,
  title: 'Green View Mess',
  description: 'Quiet mess close to campus with a shared kitchen and a reading room. ' * 4,
  approved: approved,
  division: 'Dhaka',
  district: 'Dhaka',
  area: 'Mirpur 10',
  address: 'House 12, Road 3',
  contactNumber: '01700000000',
  gender: PropertyGender.MALE,
  type: PropertyType.MESS,
  institutionNearby: 'University of Dhaka',
  facilities: const ['Wi-Fi', 'Kitchen', 'Lift', 'Generator', 'CCTV'],
  rooms: [_room(1), _room(2)],
  createdAt: _createdAt,
);

RoomTenantResponse _tenantRoom(int id) => RoomTenantResponse(
  ownerId: 9,
  ownerName: 'Karim Hossain',
  address: 'Road 5, Dhanmondi',
  area: 'Dhanmondi',
  availableSeats: 2,
  contactNumber: '01700000000',
  createdAt: '2026-01-05T10:00:00Z',
  deposit: 2000,
  description: 'Bright double room with a balcony.',
  district: 'Dhaka',
  division: 'Dhaka',
  facilities: const ['Wi-Fi', 'Kitchen'],
  gender: PropertyGender.MALE,
  images: const [],
  institutionNearby: 'University of Dhaka',
  propertyId: 4,
  propertyType: PropertyType.MESS,
  rent: 4500,
  roomHeight: 10,
  roomId: id,
  roomNumber: 'B-$id',
  roomType: RoomType.DOUBLE,
  roomWidth: 12,
  title: 'Sunny room near DU',
);

const _chat = ChatResponse(
  id: 1,
  contextId: 3,
  otherUserId: 9,
  otherUserName: 'Karim Hossain',
  lastMessagePreview: 'Is the seat still available?',
  lastMessageAt: '2026-01-05T10:00:00Z',
  unreadCount: 2,
);

const _messages = [
  ChatMessageResponse(id: 1, chatId: 1, senderId: 9, content: 'Hello!'),
  ChatMessageResponse(id: 2, chatId: 1, senderId: 1, content: 'Hi, is it available?'),
];

const _notifications = [
  NotificationResponse(id: 1, title: 'New message', body: 'Karim sent you a message'),
  NotificationResponse(id: 2, title: 'Post approved', read: true),
];

PageResponse<T> _page<T>(List<T> items) => PageResponse(content: items, last: true);

Future<void> _register({required List<String> roles}) async {
  SharedPreferences.setMockInitialValues({
    'access_token': 'token',
    'refresh_token': 'refresh',
    'user_json': jsonEncode(
      UserResponse(
        id: 1,
        fullName: 'Nadia Rahman',
        email: 'nadia@mail.com',
        phone: '01800000000',
        roles: roles,
        division: 'Dhaka',
        district: 'Dhaka',
        createdAt: '2026-01-01T00:00:00Z',
      ).toJson(),
    ),
  });
  final prefs = await SharedPreferences.getInstance();

  final chat = MockChatRepository();
  final noty = MockNotificationRepository();
  final property = MockPropertyRepository();
  final tenant = MockTenantRepository();
  final user = MockUserRepository();
  final push = MockPushService();

  when(() => chat.list(any(), size: any(named: 'size')))
      .thenAnswer((_) async => ApiSuccess(_page([_chat])));
  when(() => chat.messages(any())).thenAnswer((_) async => ApiSuccess(_page(_messages)));
  when(() => chat.liveMessage(any()))
      .thenAnswer((_) => StreamController<ChatMessageResponse>().stream);
  when(() => chat.markRead(any())).thenAnswer((_) async {});
  when(() => chat.unreadCount()).thenAnswer((_) async => 2);
  when(() => chat.open(any())).thenAnswer((_) async => const ApiSuccess(_chat));

  when(() => noty.notifications(any())).thenAnswer((_) async => ApiSuccess(_page(_notifications)));
  when(() => noty.notificationUnread()).thenAnswer((_) async => 1);
  when(() => noty.liveMessage(any()))
      .thenAnswer((_) => StreamController<NotificationResponse>().stream);

  when(() => property.getDashboardSummary()).thenAnswer(
    (_) async => const ApiSuccess(
      OwnerDashboardSummaryResponse(
        activeListings: 3,
        pendingApproval: 1,
        availableSeats: 7,
        totalRoom: 6,
        approvedRoom: 5,
        pendingRoom: 1,
      ),
    ),
  );
  when(() => property.findPage(any()))
      .thenAnswer((_) async => ApiSuccess(_page([_property(1), _property(2, approved: false)])));
  when(() => property.findAll()).thenAnswer((_) async => ApiSuccess([_property(1)]));
  when(() => property.findOne(any())).thenAnswer((_) async => ApiSuccess(_property(1)));

  when(() => tenant.findRooms(any()))
      .thenAnswer((_) async => ApiSuccess(_page([_tenantRoom(1), _tenantRoom(2)])));
  when(() => tenant.findRoom(any())).thenAnswer((_) async => ApiSuccess(_tenantRoom(1)));
  when(() => tenant.updateRoomView(any())).thenAnswer((_) async => const ApiSuccess(null));
  when(() => tenant.getSavedRooms(any())).thenAnswer((_) async => ApiSuccess([_tenantRoom(1)]));

  when(() => user.heartbeat()).thenAnswer((_) async {});
  when(() => push.registerPushToken()).thenAnswer((_) async {});

  await locator.reset();
  locator
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton(SessionManager(prefs))
    ..registerSingleton(PreferencesManager(prefs))
    ..registerSingleton(FavoritesManager(prefs)..addFavorite(1))
    ..registerSingleton<AuthRepository>(MockAuthRepository())
    ..registerSingleton<ChatRepository>(chat)
    ..registerSingleton<FileRepository>(MockFileRepository())
    ..registerSingleton<NotificationRepository>(noty)
    ..registerSingleton<PropertyRepository>(property)
    ..registerSingleton<TenantRepository>(tenant)
    ..registerSingleton<UserRepository>(user)
    ..registerSingleton<PushService>(push)
    ..registerSingleton(UnreadCountRepository(chat, noty));
}

Widget _app() => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: locator<SessionManager>()),
    ChangeNotifierProvider.value(value: locator<PreferencesManager>()),
    ChangeNotifierProvider.value(value: locator<FavoritesManager>()),
    ChangeNotifierProvider.value(value: locator<UnreadCountRepository>()),
    ChangeNotifierProvider(
      create: (_) => MainViewModel(
        userRepo: locator(),
        unreadRepo: locator(),
        notyRepo: locator(),
        preferences: locator(),
        session: locator(),
        push: locator(),
      ),
    ),
  ],
  child: const DormEasyApp(),
);

void _mockPlatform() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.example.messseat/notification'),
    (call) async => call.method == 'canPostNotifications' ? true : null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    (call) async => switch (call.method) {
      'checkPermissionStatus' => 1,
      'requestPermissions' => {17: 1},
      _ => null,
    },
  );
}

Future<void> _settle(WidgetTester tester) async {
  // shimmer and slideshows animate forever, so pump a fixed amount of time instead of settling
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _visit(WidgetTester tester, String route, {required Finder expect}) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).push(route);
  await _settle(tester);
  await tester.pump(const Duration(milliseconds: 700));
  expectLater(expect, findsWidgets);
  GoRouter.of(tester.element(find.byType(Navigator).first)).pop();
  await tester.pump(const Duration(milliseconds: 700));
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await _settle(tester);
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
    registerFallbackValue(<String, String?>{});
  });

  setUp(_mockPlatform);

  Future<void> boot(WidgetTester tester, List<String> roles) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await _register(roles: roles);
    await tester.pumpWidget(_app());
    await _settle(tester);
  }

  Future<void> shutdown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('owner can move through every screen', (tester) async {
    await boot(tester, ['OWNER']);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Listing'), findsOneWidget);

    await _tab(tester, 'Listing');
    expect(find.textContaining('Green View Mess'), findsWidgets);

    await _tab(tester, 'Chat');
    expect(find.text('Karim Hossain'), findsWidgets);

    await _tab(tester, 'Settings');
    await _tab(tester, 'Home');

    await _visit(tester, '/property/1', expect: find.textContaining('Green View Mess'));
    await _visit(tester, '/property/editor', expect: find.byType(Scaffold));
    await _visit(tester, '/conversation/1', expect: find.text('Hello!'));
    await _visit(tester, '/notifications', expect: find.text('New message'));
    await _visit(tester, '/user', expect: find.textContaining('Nadia'));

    await shutdown(tester);
  });

  testWidgets('tenant can move through every screen', (tester) async {
    await boot(tester, ['TENANT']);

    expect(find.text('Search'), findsWidgets);
    expect(find.text('Nearby rooms'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await _settle(tester);
    expect(find.textContaining('Sunny room near DU'), findsWidgets);

    await _tab(tester, 'Search');
    await _tab(tester, 'Chat');
    expect(find.text('Karim Hossain'), findsWidgets);
    await _tab(tester, 'Settings');
    await _tab(tester, 'Home');

    await _visit(tester, '/room/1', expect: find.textContaining('Sunny room near DU'));
    await _visit(tester, '/saved', expect: find.textContaining('Sunny room near DU'));
    await _visit(tester, '/conversation/1', expect: find.text('Hello!'));
    await _visit(tester, '/notifications', expect: find.text('New message'));
    await _visit(tester, '/user', expect: find.textContaining('Nadia'));

    await shutdown(tester);
  });

  testWidgets('logging out returns to the login screen', (tester) async {
    await boot(tester, ['TENANT']);

    await locator<SessionManager>().clear();
    await _settle(tester);

    expect(find.text('Welcome Back'), findsOneWidget);
    await shutdown(tester);
  });
}
