import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/domain/enums/gender.dart';
import 'package:messseat/domain/enums/user_role.dart';
import 'package:messseat/features/auth/auth_event.dart';
import 'package:messseat/features/auth/signup/password_strength.dart';
import 'package:messseat/features/auth/signup/signup_step.dart';
import 'package:messseat/features/auth/signup/signup_view_model.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthRepository repo;
  late SignupViewModel vm;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repo = MockAuthRepository();
    vm = SignupViewModel(repo);
    when(() => repo.verifyEmail(any())).thenAnswer((_) async => const ApiSuccess(null));
  });

  tearDown(() => vm.dispose());

  Future<void> fillUntil(SignupStep step) async {
    vm.onRoleSelected(UserRole.OWNER);
    await vm.onGoNext();
    if (step == SignupStep.basicInfo) return;

    vm
      ..onFullNameChange('Rahim Uddin')
      ..onEmailChange('rahim@mail.com')
      ..onPhoneChange('01712345678');
    await vm.onGoNext();
    if (step == SignupStep.aboutYou) return;

    vm.onGenderSelected(Gender.MALE);
    await vm.onGoNext();
    if (step == SignupStep.location) return;

    vm
      ..onDivisionSelected('Dhaka')
      ..onDistrictSelected('Dhaka')
      ..onAreaSelected('Mirpur');
    await vm.onGoNext();
  }

  group('password', () {
    test('strength follows the number of met requirements', () {
      final cases = {
        '': PasswordStrength.empty,
        'abc': PasswordStrength.weak,
        'abcdefgh': PasswordStrength.weak,
        'Abcdefgh': PasswordStrength.fair,
        'Abcdefg1': PasswordStrength.medium,
        'Abcdef1!': PasswordStrength.strong,
      };
      for (final MapEntry(key: pwd, value: expected) in cases.entries) {
        vm.onPasswordChange(pwd);
        expect(vm.state.strength, expected, reason: pwd);
      }
    });

    test('requirements are tracked individually and input is trimmed', () {
      vm.onPasswordChange('  abc1  ');
      final rqm = vm.state.passwordRequirements;

      expect(vm.state.password, 'abc1');
      expect(rqm.hasMinLength, isFalse);
      expect(rqm.hasUppercase, isFalse);
      expect(rqm.hasNumber, isTrue);
      expect(rqm.hasSpacialChar, isFalse);
      expect(rqm.isValid, isFalse);
    });
  });

  test('role step needs a role before moving on', () async {
    await vm.onGoNext();
    expect(vm.state.currentStep, SignupStep.roleSelection);

    vm.onRoleSelected(UserRole.TENANT);
    await vm.onGoNext();
    expect(vm.state.currentStep, SignupStep.basicInfo);
    expect(vm.state.isLoading, isFalse);
  });

  test('phone keeps only the first 11 digits', () {
    vm.onPhoneChange('+88 0171-234-5678');
    expect(vm.state.phone, '88017123456');
  });

  group('basic info', () {
    test('flags every invalid field and skips the email lookup', () async {
      await fillUntil(SignupStep.basicInfo);
      vm.onEmailChange('not-an-email');
      vm.onPhoneChange('0123');
      await vm.onGoNext();

      expect(vm.state.currentStep, SignupStep.basicInfo);
      expect(vm.state.fullNameError, 'Please enter your full name.');
      expect(vm.state.emailError, 'Enter a valid email address.');
      expect(vm.state.phoneError, 'Enter a valid phone number.');
      verifyNever(() => repo.verifyEmail(any()));
    });

    test('shows the server message when the email is taken', () async {
      when(() => repo.verifyEmail(any()))
          .thenAnswer((_) async => const ApiError('Email already registered'));

      await fillUntil(SignupStep.basicInfo);
      vm
        ..onFullNameChange('Rahim')
        ..onEmailChange(' taken@mail.com ')
        ..onPhoneChange('01812345678');
      await vm.onGoNext();

      expect(vm.state.emailError, 'Email already registered');
      expect(vm.state.currentStep, SignupStep.basicInfo);
      final captured = verify(() => repo.verifyEmail(captureAny())).captured;
      expect((captured.single as EmailRequest).email, 'taken@mail.com');
    });
  });

  test('about you requires a gender', () async {
    await fillUntil(SignupStep.aboutYou);
    await vm.onGoNext();

    expect(vm.state.genderError, 'Please select your gender');
    vm.onGenderSelected(Gender.FEMALE);
    expect(vm.state.genderError, isNull);
  });

  test('location requires division, district and area', () async {
    await fillUntil(SignupStep.location);
    await vm.onGoNext();

    expect(vm.state.divisionError, 'Please select your division.');
    expect(vm.state.districtError, 'Please select your district.');
    expect(vm.state.areaError, 'Please enter your area.');
    expect(vm.state.currentStep, SignupStep.location);
  });

  group('security', () {
    test('weak password reports what is missing', () async {
      await fillUntil(SignupStep.security);
      vm.onPasswordChange('abc');
      await vm.onGoNext();

      expect(
        vm.state.passwordError,
        'Password must include at least 8 characters, 1 uppercase letter, 1 number, '
        '1 special character.',
      );
    });

    test('confirmation and terms are checked', () async {
      await fillUntil(SignupStep.security);
      vm
        ..onPasswordChange('Secret1!')
        ..onConfirmPassChange('Secret2!');
      await vm.onGoNext();

      expect(vm.state.confirmPasswordError, "Passwords don't match");
      expect(vm.state.termsError, 'Please agree to the Terms & Conditions');
      verifyNever(() => repo.register(any()));
    });

    test('creates the account and asks for verification', () async {
      when(() => repo.register(any())).thenAnswer((_) async => const ApiSuccess(UserResponse()));
      final events = <AuthEvent>[];
      vm.events.listen(events.add);

      await fillUntil(SignupStep.security);
      vm
        ..onPasswordChange('Secret1!')
        ..onConfirmPassChange('Secret1!')
        ..onTermsToggle(true);
      await vm.onGoNext();
      await pumpEventQueue();

      final req = verify(() => repo.register(captureAny())).captured.single as RegisterRequest;
      expect(req.role, Role.OWNER);
      expect(req.gender, Gender.MALE);
      expect(req.email, 'rahim@mail.com');
      expect(req.area, 'Mirpur');
      expect(req.termsAccepted, isTrue);
      expect(events.single, isA<GoVerify>().having((e) => e.email, 'email', 'rahim@mail.com'));
      expect(vm.state.isLoading, isFalse);
    });

    test('register failure is surfaced as an error toast', () async {
      when(() => repo.register(any())).thenAnswer((_) async => const ApiError('Server down'));
      final events = <AuthEvent>[];
      vm.events.listen(events.add);

      await fillUntil(SignupStep.security);
      vm
        ..onPasswordChange('Secret1!')
        ..onConfirmPassChange('Secret1!')
        ..onTermsToggle(true);
      await vm.onGoNext();
      await pumpEventQueue();

      expect(
        events.single,
        isA<Toast>()
            .having((e) => e.message, 'message', 'Server down')
            .having((e) => e.isError, 'isError', isTrue),
      );
    });
  });

  test('going back walks the steps in reverse', () async {
    await fillUntil(SignupStep.location);

    vm.onGoBack();
    expect(vm.state.currentStep, SignupStep.aboutYou);
    expect(vm.state.isNavigatingForward, isFalse);

    vm
      ..onGoBack()
      ..onGoBack()
      ..onGoBack();
    expect(vm.state.currentStep, SignupStep.roleSelection);
  });
}
