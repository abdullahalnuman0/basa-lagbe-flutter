import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/features/auth/auth_event.dart';
import 'package:messseat/features/auth/forget/forget_pwd_step.dart';
import 'package:messseat/features/auth/forget/forget_pwd_view_model.dart';
import 'package:messseat/features/auth/signup/password_strength.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthRepository repo;
  late ForgetPwdViewModel vm;

  setUp(() {
    repo = MockAuthRepository();
    vm = ForgetPwdViewModel(repo);
    when(() => repo.forgotPassword(any()))
        .thenAnswer((_) async => const ApiSuccess(MessageResponse('sent')));
  });

  tearDown(() => vm.dispose());

  test('invalid email never reaches the server', () async {
    vm.onEmailChange('nope');
    await vm.onGoNext();

    expect(vm.state.emailError, 'Enter a valid email address.');
    expect(vm.state.currentStep, ForgetPwdStep.email);
    verifyNever(() => repo.forgotPassword(any()));
  });

  test('unknown account shows the server message', () async {
    when(() => repo.forgotPassword(any())).thenAnswer((_) async => const ApiError('No account'));

    vm.onEmailChange('ghost@mail.com');
    await vm.onGoNext();

    expect(vm.state.emailError, 'No account');
    expect(vm.state.currentStep, ForgetPwdStep.email);
  });

  test('a valid email moves on to the password step', () async {
    vm.onEmailChange(' me@mail.com ');
    expect(vm.state.email, 'me@mail.com');

    await vm.onGoNext();

    verify(() => repo.forgotPassword('me@mail.com')).called(1);
    expect(vm.state.currentStep, ForgetPwdStep.password);
    expect(vm.state.isNavForward, isTrue);
    expect(vm.state.isLoading, isFalse);
  });

  test('change email clears it and goes back', () async {
    vm.onEmailChange('me@mail.com');
    await vm.onGoNext();

    vm.changeEmail();

    expect(vm.state.email, isEmpty);
    expect(vm.state.currentStep, ForgetPwdStep.email);
    expect(vm.state.isNavForward, isFalse);
  });

  test('weak new password is rejected before reset', () async {
    vm.onEmailChange('me@mail.com');
    await vm.onGoNext();

    vm.onPasswordChange('Password');
    expect(vm.state.strength, PasswordStrength.fair);
    await vm.onGoNext();

    expect(vm.state.passwordError, 'Password must include 1 number, 1 special character.');
    verifyNever(() => repo.resetPassword(any(), any(), any()));
  });

  test('successful reset tells the user and returns to login', () async {
    when(() => repo.resetPassword(any(), any(), any()))
        .thenAnswer((_) async => const ApiSuccess(MessageResponse(null)));
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    vm.onEmailChange('me@mail.com');
    await vm.onGoNext();
    vm
      ..onOtpChange('112233')
      ..onPasswordChange('NewPass1!');
    await vm.onGoNext();
    await pumpEventQueue();

    verify(() => repo.resetPassword('me@mail.com', '112233', 'NewPass1!')).called(1);
    expect(events, [
      isA<Toast>().having((e) => e.message, 'msg', 'Password changed — please log in'),
      isA<GoLogin>(),
    ]);
  });

  test('failed reset only shows the error', () async {
    when(() => repo.resetPassword(any(), any(), any()))
        .thenAnswer((_) async => const ApiError('Code expired'));
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    vm.onEmailChange('me@mail.com');
    await vm.onGoNext();
    vm
      ..onOtpChange('000000')
      ..onPasswordChange('NewPass1!');
    await vm.onGoNext();
    await pumpEventQueue();

    expect(events.single, isA<Toast>().having((e) => e.message, 'msg', 'Code expired'));
    expect(vm.state.isLoading, isFalse);
  });
}
