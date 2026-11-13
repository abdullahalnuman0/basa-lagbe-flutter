import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/components/snackbar.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/features/owner/property_details/property_details_screen.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

import '../home/fixtures.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  late MockPropertyRepository repo;

  setUp(() {
    repo = MockPropertyRepository();
    locator
      ..registerSingleton<PropertyRepository>(repo)
      ..registerSingleton<FileRepository>(MockFileRepository());
  });

  tearDown(locator.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        scaffoldMessengerKey: AppSnackbar.messengerKey,
        home: const Scaffold(body: PropertyDetailsScreen(propertyId: 7)),
      ),
    );
  }

  testWidgets('shows the property once it is loaded', (tester) async {
    when(() => repo.findOne(7)).thenAnswer(
      (_) async => ApiSuccess(
        property(
          id: 7,
          rooms: [
            room(id: 1, number: '101'),
            room(id: 2, number: '102', seats: 0),
          ],
        ),
      ),
    );

    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Green Villa'), findsOneWidget);
    expect(find.text('Approved & Live'), findsOneWidget);
    expect(find.text('Rooms (2)'), findsOneWidget);
    expect(find.text('Room 101'), findsOneWidget);
    expect(find.text('Full'), findsOneWidget);
    expect(find.text('+8801700000000'), findsOneWidget);
  });

  testWidgets('filters rooms by the search text', (tester) async {
    when(() => repo.findOne(7)).thenAnswer(
      (_) async => ApiSuccess(
        property(
          id: 7,
          rooms: [
            room(id: 1, number: '101'),
            room(id: 2, number: '204'),
          ],
        ),
      ),
    );

    await pumpScreen(tester);
    await tester.pump();

    await tester.enterText(find.byType(TextField), '20');
    await tester.pump();

    expect(find.text('Room 101'), findsNothing);
    expect(find.text('Room 204'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '999');
    await tester.pump();

    expect(find.text('No rooms found'), findsOneWidget);
  });

  testWidgets('offers a retry when loading fails', (tester) async {
    when(() => repo.findOne(7)).thenAnswer((_) async => const ApiError('Not found'));

    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Not found'), findsOneWidget);

    when(() => repo.findOne(7)).thenAnswer((_) async => ApiSuccess(property(id: 7)));
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Green Villa'), findsOneWidget);
  });
}
