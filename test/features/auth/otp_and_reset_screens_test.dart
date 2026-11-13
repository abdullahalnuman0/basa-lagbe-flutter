import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/components/snackbar.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/repository/auth_repository.dart';
import 'package:messseat/domain/enums/gender.dart';
import 'package:messseat/domain/enums/user_role.dart';
import 'package:messseat/features/auth/forget/forget_pwd_screen.dart';
import 'package:messseat/features/auth/otp/otp_screen.dart';
import 'package:messseat/features/auth/signup/components/location_section.dart';
import 'package:messseat/features/auth/signup/signup_step.dart';
import 'package:messseat/features/auth/signup/signup_ui_state.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    locator.registerSingleton<AuthRepository>(repo);
  });

  tearDown(() => locator.reset());

  Widget app(Widget home) =>
      MaterialApp(theme: lightTheme, scaffoldMessengerKey: AppSnackbar.messengerKey, home: home);

  testWidgets('otp screen sends a code on open and verifies the typed digits', (tester) async {
    when(() => repo.resendOtp(any()))
        .thenAnswer((_) async => const ApiSuccess(MessageResponse('Code sent')));
    when(() => repo.verifyOtp(any(), any())).thenAnswer((_) async => const ApiError('Wrong code'));

    await tester.pumpWidget(app(const OtpScreen(email: 'karim@mail.com', recover: false)));
    await tester.pump();

    verify(() => repo.resendOtp('karim@mail.com')).called(1);
    expect(find.textContaining('(ka...@mail.com)'), findsOneWidget);
    expect(find.text('Code sent'), findsOneWidget);
    expect(find.text('Resend in 0:30'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '12ab3456');
    await tester.pump();
    expect(find.text('6'), findsOneWidget);

    await tester.tap(find.text('Verify OTP'));
    await tester.pump();
    await tester.pump();

    verify(() => repo.verifyOtp('karim@mail.com', '123456')).called(1);
    expect(find.text('Wrong code'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('forget password moves to the reset step', (tester) async {
    when(() => repo.forgotPassword(any()))
        .thenAnswer((_) async => const ApiSuccess(MessageResponse(null)));

    await tester.pumpWidget(app(const ForgetPwdScreen()));
    expect(find.text('Forget Password'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'karim@mail.com');
    await tester.pump();
    await tester.tap(find.text('Send Verification Code'));
    await tester.pumpAndSettle();

    expect(find.text('Verify & Set Your Password'), findsOneWidget);
    expect(find.text('@mail.com'), findsOneWidget);

    await tester.tap(find.text('Change email'));
    await tester.pumpAndSettle();
    expect(find.text('Forget Password'), findsOneWidget);
  });

  testWidgets('division dropdown lists divisions and reports the pick', (tester) async {
    String? picked;
    const state = SignupUiState(
      currentStep: SignupStep.location,
      selectedRole: UserRole.TENANT,
      gender: Gender.MALE,
    );

    await tester.pumpWidget(
      app(
        Scaffold(
          body: LocationSection(
            state: state,
            onDivisionSelected: (v) => picked = v,
            onDistrictSelected: (_) {},
            onAreaSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    expect(find.text('Sylhet'), findsOneWidget);

    await tester.tap(find.text('Sylhet'));
    await tester.pumpAndSettle();
    expect(picked, 'Sylhet');
    expect(find.byType(MenuItemButton), findsNothing);
  });
}
