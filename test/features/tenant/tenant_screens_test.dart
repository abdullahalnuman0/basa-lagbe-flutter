import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/favorites_manager.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/components/snackbar.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/data/repository/chat_repository.dart';
import 'package:messseat/data/repository/tenant_repository.dart';
import 'package:messseat/features/tenant/room_details/room_details_screen.dart';
import 'package:messseat/features/tenant/saved_post/saved_post_screen.dart';
import 'package:messseat/features/tenant/search/search_screen.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

void main() {
  late MockTenantRepository tenantRepo;
  late FavoritesManager favorites;
  late SessionManager session;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    favorites = FavoritesManager(prefs);
    session = SessionManager(prefs);
    tenantRepo = MockTenantRepository();
    locator
      ..registerSingleton<SessionManager>(session)
      ..registerSingleton<TenantRepository>(tenantRepo)
      ..registerSingleton<ChatRepository>(MockChatRepository())
      ..registerSingleton<FavoritesManager>(favorites);
  });

  tearDown(() => locator.reset());

  Widget app(Widget screen) => MaterialApp(
    theme: lightTheme,
    scaffoldMessengerKey: AppSnackbar.messengerKey,
    home: Scaffold(body: screen),
  );

  group('SavedPostScreen', () {
    testWidgets('shows the empty state when nothing is saved', (tester) async {
      await tester.pumpWidget(app(const SavedPostScreen()));
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('No room saved'), findsOneWidget);
      expect(find.text("You don't save any rooms."), findsOneWidget);
    });

    testWidgets('lists the saved rooms', (tester) async {
      await favorites.addFavorite(2);
      when(() => tenantRepo.getSavedRooms(any()))
          .thenAnswer((_) async => ApiSuccess([room(id: 2, title: 'Quiet seat in Mirpur')]));

      await tester.pumpWidget(app(const SavedPostScreen()));
      await tester.pump();

      expect(find.text('Quiet seat in Mirpur'), findsOneWidget);
      expect(find.text('A-2'), findsOneWidget);
      expect(find.text('৳4,500'), findsOneWidget);
    });
  });

  group('RoomDetailsScreen', () {
    testWidgets('shows the room and saves it', (tester) async {
      when(() => tenantRepo.findRoom(any()))
          .thenAnswer((_) async => ApiSuccess(room(id: 11, description: 'Bright and airy.')));

      await tester.pumpWidget(app(const RoomDetailsScreen(roomId: 11)));
      await tester.pump();

      expect(find.text('Karim Hossain'), findsOneWidget);
      expect(find.text('Road 5, Dhanmondi, Dhaka'), findsOneWidget);
      expect(find.text('Facilities & Amenities'), findsOneWidget);
      expect(find.text('About this Property'), findsOneWidget);
      expect(find.text('2 Available Seats'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(favorites.isFavorite(11), isTrue);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Save post'), findsOneWidget);
    });

    testWidgets('offers a retry when loading fails', (tester) async {
      when(() => tenantRepo.findRoom(any())).thenAnswer((_) async => const ApiError('Gone'));

      await tester.pumpWidget(app(const RoomDetailsScreen(roomId: 11)));
      await tester.pump();

      expect(find.text('Gone'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('SearchScreen', () {
    setUp(() async {
      await session.updateUser(const UserResponse(id: 1, division: 'Dhaka', district: 'Gazipur'));
      when(() => tenantRepo.findRooms(any()))
          .thenAnswer((_) async => ApiSuccess(page([room(id: 4, title: 'Corner room')])));
    });

    testWidgets('filters are applied from the bottom sheet', (tester) async {
      await tester.pumpWidget(app(const SearchScreen()));
      await tester.pump();

      expect(find.text('Find a Room'), findsOneWidget);
      expect(find.text('Corner room(A-4)', findRichText: true), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);

      await tester.tap(find.text('Single'));
      await tester.pump();
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();

      expect(find.text('Apply filters'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      final params = verify(() => tenantRepo.findRooms(captureAny())).captured.last as Map;
      expect(params['roomType'], 'SINGLE');
      expect(params['district'], 'Gazipur');
    });

    testWidgets('close button dismisses the sheet without searching', (tester) async {
      await tester.pumpWidget(app(const SearchScreen()));
      await tester.pump();

      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Apply filters'), findsNothing);
      verify(() => tenantRepo.findRooms(any())).called(1);
    });
  });
}
