import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/domain/model/room.dart';
import 'package:messseat/features/owner/property_add_edit/property_editor_ui_state.dart';
import 'package:messseat/features/owner/property_add_edit/room_section/room_editor_section.dart';
import 'package:messseat/features/owner/property_add_edit/room_section/room_editor_view_model.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockFileRepository extends Mock implements FileRepository {}

void main() {
  late _MockFileRepository fileRepo;
  late RoomEditorViewModel roomVm;
  late List<Room> added;

  setUp(() {
    fileRepo = _MockFileRepository();
    roomVm = RoomEditorViewModel(fileRepo);
    added = [];
    when(() => fileRepo.deleteAll(any())).thenAnswer((_) async => const ApiSuccess(null));
  });

  Future<void> pumpSection(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: roomVm,
            child: RoomEditorSection(
              state: PropertyEditorUiState(),
              onAddRoom: added.add,
              onRemoveRoom: (_) {},
              onUpdateRoom: (_, _) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('add room sheet validates before saving', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('Add Room'));
    await tester.pumpAndSettle();
    expect(find.text('Add new room'), findsOneWidget);

    await tester.tap(find.text('Save room'));
    await tester.pumpAndSettle();

    expect(find.text('Room number is required.'), findsOneWidget);
    expect(find.text('Please select at last one image.'), findsOneWidget);
    expect(find.text('Add new room'), findsOneWidget);
    expect(added, isEmpty);
  });

  testWidgets('cancel closes the sheet and resets the form', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('Add Room'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'R-9');
    expect(roomVm.state.roomNumber, 'R-9');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add new room'), findsNothing);
    expect(roomVm.state.roomNumber, isEmpty);
    verify(() => fileRepo.deleteAll(const [])).called(1);
  });
}
