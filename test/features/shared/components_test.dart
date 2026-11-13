import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/features/shared/conversation/components/input_section.dart';
import 'package:messseat/features/shared/settings/components/notification_section.dart';
import 'package:messseat/features/shared/settings/setting_preferences.dart';
import 'package:messseat/ui/theme/theme.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('InputSection', () {
    testWidgets('sends the typed text and clears the field', (tester) async {
      final sent = <String>[];
      await tester.pumpWidget(
        wrap(
          InputSection(
            uploading: false,
            sending: false,
            onMessageSend: sent.add,
            onSelectImage: () {},
          ),
        ),
      );

      final sendButton = find.widgetWithIcon(IconButton, Icons.send);
      expect(tester.widget<IconButton>(sendButton).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Hello there');
      await tester.pump();
      await tester.tap(sendButton);
      await tester.pump();

      expect(sent, ['Hello there']);
      expect(find.text('Hello there'), findsNothing);
    });

    testWidgets('locks the image button while uploading', (tester) async {
      await tester.pumpWidget(
        wrap(
          InputSection(
            uploading: true,
            sending: false,
            onMessageSend: (_) {},
            onSelectImage: () => fail('should be disabled'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<IconButton>(find.byType(IconButton).first).onPressed, isNull);
    });
  });

  group('NotificationSection', () {
    Widget section({
      bool allowed = true,
      SettingPreferences state = const SettingPreferences(),
      ValueChanged<bool>? onSound,
      VoidCallback? onRequest,
    }) => wrap(
      NotificationSection(
        state: state,
        notificationsAllowed: allowed,
        onInAppNoty: (_) {},
        onSound: onSound ?? (_) {},
        onVibration: (_) {},
        onRequestNotifications: onRequest ?? () {},
      ),
    );

    testWidgets('asks for permission only when notifications are blocked', (tester) async {
      var requested = false;
      await tester.pumpWidget(section(allowed: false, onRequest: () => requested = true));

      await tester.tap(find.text('Enable Notifications'));
      expect(requested, isTrue);

      await tester.pumpWidget(section());
      expect(find.text('Enable Notifications'), findsNothing);
    });

    testWidgets('sound follows the in-app switch', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        section(
          state: const SettingPreferences(inAppNotificationEnable: false),
          onSound: changes.add,
        ),
      );

      await tester.tap(find.text('Sound'));
      expect(changes, isEmpty);

      await tester.pumpWidget(section(onSound: changes.add));
      await tester.tap(find.text('Sound'));
      expect(changes, [false]);
    });
  });
}
