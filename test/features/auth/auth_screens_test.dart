import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/components/snackbar.dart';
import 'package:messseat/data/repository/auth_repository.dart';
import 'package:messseat/features/auth/signin/signing_screen.dart';
import 'package:messseat/features/auth/signup/signup_screen.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthRepository repo;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repo = MockAuthRepository();
    locator.registerSingleton<AuthRepository>(repo);
  });

  tearDown(() => locator.reset());

  Widget app(Widget home) =>
      MaterialApp(theme: lightTheme, scaffoldMessengerKey: AppSnackbar.messengerKey, home: home);

  FilledButton loginButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Login'));

  group('SigningScreen', () {
    testWidgets('login is enabled only once both fields are filled', (tester) async {
      await tester.pumpWidget(app(const SigningScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(loginButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField).at(0), 'me@mail.com');
      await tester.pump();
      expect(loginButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField).at(1), 'secret');
      await tester.pump();
      expect(loginButton(tester).onPressed, isNotNull);
    });

    testWidgets('shows the error returned by the server', (tester) async {
      when(() => repo.login(any(), any()))
          .thenAnswer((_) async => const ApiError('Invalid email or password'));

      await tester.pumpWidget(app(const SigningScreen()));
      await tester.enterText(find.byType(TextField).at(0), 'me@mail.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      await tester.pump();

      await tester.ensureVisible(find.text('Login'));
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
      verify(() => repo.login('me@mail.com', 'wrong')).called(1);
    });
  });

  group('SignupScreen', () {
    testWidgets('continue stays disabled until a role is picked', (tester) async {
      await tester.pumpWidget(app(const SignupScreen()));

      expect(find.text('What are you looking tor?'), findsOneWidget);
      final button = find.widgetWithText(ElevatedButton, 'Continue');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      await tester.ensureVisible(find.text('Find a place'));
      await tester.tap(find.text('Find a place'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    });

    testWidgets('basic info validates before moving on', (tester) async {
      await tester.pumpWidget(app(const SignupScreen()));

      await tester.ensureVisible(find.text('Rent out a place'));
      await tester.tap(find.text('Rent out a place'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text("Let's get started"), findsOneWidget);
      expect(find.text('Step 2 of 5'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Enter a valid phone number.'), findsOneWidget);
      verifyNever(() => repo.verifyEmail(any()));
    });
  });
}
