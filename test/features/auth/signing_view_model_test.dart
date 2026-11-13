import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/features/auth/auth_event.dart';
import 'package:messseat/features/auth/signin/signing_view_model.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthRepository repo;
  late SigningViewModel vm;

  setUp(() {
    repo = MockAuthRepository();
    vm = SigningViewModel(repo);
  });

  tearDown(() => vm.dispose());

  test('typing clears the previous error', () async {
    when(() => repo.login(any(), any())).thenAnswer((_) async => const ApiError('Wrong password'));

    vm
      ..onEmailChange('a@b.com')
      ..onPwdChange('secret');
    await vm.login();
    expect(vm.state.error, 'Wrong password');

    vm.onPwdChange('secret2');
    expect(vm.state.error, isNull);
  });

  test('login trims credentials and stops loading on success', () async {
    when(() => repo.login('user@mail.com', 'pass'))
        .thenAnswer((_) async => const ApiSuccess(AuthResponse()));

    vm
      ..onEmailChange('  user@mail.com ')
      ..onPwdChange(' pass ');
    final pending = vm.login();
    expect(vm.state.isLoading, isTrue);
    await pending;

    expect(vm.state.isLoading, isFalse);
    expect(vm.state.error, isNull);
    verify(() => repo.login('user@mail.com', 'pass')).called(1);
  });

  test('unverified email sends the user to otp', () async {
    when(() => repo.login(any(), any()))
        .thenAnswer((_) async => const ApiError('Email not verified', code: 'EMAIL_NOT_VERIFIED'));
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    vm
      ..onEmailChange('new@mail.com ')
      ..onPwdChange('pass');
    await vm.login();
    await pumpEventQueue();

    expect(vm.state.error, 'Email not verified');
    expect(events.single, isA<GoVerify>().having((e) => e.email, 'email', 'new@mail.com'));
  });
}
