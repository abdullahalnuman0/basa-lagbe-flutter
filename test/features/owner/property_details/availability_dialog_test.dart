import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/features/owner/property_details/components/room/availability_dialog.dart';
import 'package:messseat/ui/theme/theme.dart';

void main() {
  Future<List<int>> openDialog(WidgetTester tester) async {
    final saved = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAvailabilityDialog(
                context,
                roomNumber: '101',
                availableSeats: 2,
                onSave: saved.add,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return saved;
  }

  FilledButton saveButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));

  testWidgets('save stays disabled until the value changes', (tester) async {
    final saved = await openDialog(tester);

    expect(find.text('Room 101 Availability'), findsOneWidget);
    expect(find.text('Currently available: 2'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await tester.tap(find.byTooltip('Increase availability'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, [3]);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('an empty value is rejected', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(find.text('Please enter a valid number'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('cancel closes without saving', (tester) async {
    final saved = await openDialog(tester);

    await tester.tap(find.byTooltip('Decrease availability'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
  });
}
