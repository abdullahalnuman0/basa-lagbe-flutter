import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/features/auth/auth_event.dart';
import 'package:messseat/features/auth/otp/otp_view_model.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  testWidgets('resend starts a cooldown that grows each time', (tester) async {
    when(() => repo.resendOtp(any()))
        .thenAnswer((_) async => const ApiSuccess(MessageResponse(null)));
    final vm = OtpViewModel(repo);
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    await vm.resend('a@b.com', false);
    await tester.pump();
    expect(vm.state.resendCount, 1);
    expect(vm.state.resendCooldown, 30);
    expect(vm.state.isResendCount, isTrue);
    expect(
      events.single,
      isA<Toast>().having((e) => e.message, 'msg', 'A new code has been sent.'),
    );

    // ignored while the countdown is running
    await vm.resend('a@b.com', false);
    verify(() => repo.resendOtp('a@b.com')).called(1);

    await tester.pump(const Duration(seconds: 10));
    expect(vm.state.resendCooldown, 20);

    await tester.pump(const Duration(seconds: 20));
    expect(vm.state.resendCooldown, 0);
    expect(vm.state.isResendCount, isFalse);

    await vm.resend('a@b.com', false);
    expect(vm.state.resendCooldown, 45);
    expect(vm.state.resendCount, 2);

    vm.dispose();
  });

  test('resend failure is shown to the user', () async {
    when(() => repo.resendOtp(any())).thenAnswer((_) async => const ApiError('Too many requests'));
    final vm = OtpViewModel(repo);
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    await vm.resend('a@b.com', false);
    await pumpEventQueue();

    expect(events.single, isA<Toast>().having((e) => e.message, 'msg', 'Too many requests'));
    expect(vm.state.isLoading, isFalse);
    expect(vm.state.isSending, isFalse);
    vm.dispose();
  });

  test('verify sends the typed code and reports errors', () async {
    when(() => repo.verifyOtp(any(), any()))
        .thenAnswer((_) async => const ApiError('Invalid code'));
    final vm = OtpViewModel(repo);
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    vm.onOtpChange('123456');
    await vm.verifyOtp('a@b.com', false);
    await pumpEventQueue();

    verify(() => repo.verifyOtp('a@b.com', '123456')).called(1);
    expect(events.single, isA<Toast>().having((e) => e.message, 'msg', 'Invalid code'));
    expect(vm.state.isLoading, isFalse);
    vm.dispose();
  });

  test('successful verify stays quiet, the session takes over', () async {
    when(() => repo.verifyOtp(any(), any()))
        .thenAnswer((_) async => const ApiSuccess(AuthResponse()));
    final vm = OtpViewModel(repo);
    final events = <AuthEvent>[];
    vm.events.listen(events.add);

    vm.onOtpChange('654321');
    await vm.verifyOtp('a@b.com', false);
    await pumpEventQueue();

    expect(events, isEmpty);
    vm.dispose();
  });
}
