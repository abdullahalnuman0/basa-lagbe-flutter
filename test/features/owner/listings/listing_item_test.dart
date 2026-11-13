import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/features/owner/home/components/listing_item.dart';
import 'package:messseat/ui/theme/theme.dart';

import '../home/fixtures.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  testWidgets('summarises the rooms and wires the buttons', (tester) async {
    var edits = 0;
    var views = 0;
    await pump(
      tester,
      ListingItem(
        property: property(
          approved: false,
          rooms: [room(id: 1, seats: 2), room(id: 2, seats: 3, rent: 4500)],
        ),
        moreContent: ListingItemBtns(onEdit: () => edits++, onView: () => views++),
      ),
    );

    expect(find.text('Green Villa'), findsOneWidget);
    expect(find.text('Pending Approval'), findsOneWidget);
    expect(find.text('2 Rooms'), findsOneWidget);
    expect(find.text('5 Available Seats'), findsOneWidget);
    expect(find.text('৳3,000/SEAT'), findsOneWidget);

    // the card cycles through the rooms every few seconds
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('৳4,500/SEAT'), findsOneWidget);

    await tester.tap(find.text('Edit Listing'));
    await tester.tap(find.text('View Details'));
    expect(edits, 1);
    expect(views, 1);
  });

  testWidgets('renders nothing for a property without rooms', (tester) async {
    await pump(tester, ListingItem(property: property()));

    expect(find.text('Green Villa'), findsNothing);
  });
}
