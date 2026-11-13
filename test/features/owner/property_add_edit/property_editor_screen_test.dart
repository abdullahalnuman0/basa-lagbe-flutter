import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/domain/enums/property_gender.dart';
import 'package:messseat/domain/enums/property_type.dart';
import 'package:messseat/features/owner/property_add_edit/property_editor_screen.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

class _MockFileRepository extends Mock implements FileRepository {}

class _MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  setUp(() {
    locator
      ..registerSingleton<FileRepository>(_MockFileRepository())
      ..registerSingleton<PropertyRepository>(_MockPropertyRepository());
  });

  tearDown(() => locator.reset());

  Future<void> pumpEditor(WidgetTester tester, {PropertyResponse? property}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: PropertyEditorScreen(updateProperty: property),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the property details step of a new listing', (tester) async {
    await pumpEditor(tester);

    expect(find.text('Create Listing'), findsOneWidget);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text('Property details'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('asks for a type before moving on', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Please select a property type.'), findsOneWidget);
    expect(find.text('Step 1 of 5'), findsOneWidget);
  });

  testWidgets('moves to basic info once type and occupants are picked', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.text('Hostel'));
    await tester.tap(find.text('Any'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 5'), findsOneWidget);
    expect(find.text('Contact Number'), findsOneWidget);
    expect(find.text('Listing Title'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 5'), findsOneWidget);
  });

  testWidgets('edit mode is prefilled and has four steps', (tester) async {
    await pumpEditor(
      tester,
      property: PropertyResponse(
        id: 3,
        title: 'Lake View Mess',
        description: '',
        approved: true,
        division: 'Dhaka',
        district: 'Dhaka',
        area: 'Mirpur',
        address: 'Road 1',
        contactNumber: '01812345678',
        gender: PropertyGender.FEMALE,
        type: PropertyType.MESS,
        institutionNearby: '',
        facilities: const ['Gas'],
        rooms: const [],
        createdAt: DateTime(2025),
      ),
    );

    expect(find.text('Edit Listing'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Lake View Mess'), findsOneWidget);
    expect(find.text('01812345678'), findsOneWidget);
  });
}
