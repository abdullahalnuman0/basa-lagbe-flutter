import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/features/owner/home/components/feed_tabs.dart';
import 'package:messseat/ui/theme/theme.dart';

void main() {
  testWidgets('shows counts only when there is something to count', (tester) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          body: FeedTabs(
            totalRoom: 5,
            approved: 5,
            pending: 0,
            selected: 0,
            onSelect: (i) => selected = i,
          ),
        ),
      ),
    );

    expect(find.text('All (5)'), findsOneWidget);
    expect(find.text('Approved (5)'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    await tester.tap(find.text('Pending'));
    expect(selected, 2);
  });
}
