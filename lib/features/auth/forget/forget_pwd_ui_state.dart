import '../signup/password_requirements.dart';
import '../signup/password_strength.dart';
import 'forget_pwd_step.dart';

class ForgetPwdUiState {
  const ForgetPwdUiState({
    this.currentStep = ForgetPwdStep.email,
    this.isNavForward = true,
    this.email = '',
    this.emailError,
    this.otpCode = '',
    this.password = '',
    this.passwordError,
    this.passwordRequirements = const PasswordRequirements(),
    this.strength = PasswordStrength.empty,
    this.isLoading = false,
  });

  final ForgetPwdStep currentStep;
  final bool isNavForward;

  final String email;
  final String? emailError;
  final String otpCode;
  final String password;
  final String? passwordError;
  final PasswordRequirements passwordRequirements;
  final PasswordStrength strength;

  final bool isLoading;

  static const _unset = Object();

  ForgetPwdUiState copyWith({
    ForgetPwdStep? currentStep,
    bool? isNavForward,
    String? email,
    Object? emailError = _unset,
    String? otpCode,
    String? password,
    Object? passwordError = _unset,
    PasswordRequirements? passwordRequirements,
    PasswordStrength? strength,
    bool? isLoading,
  }) {
    return ForgetPwdUiState(
      currentStep: currentStep ?? this.currentStep,
      isNavForward: isNavForward ?? this.isNavForward,
      email: email ?? this.email,
      emailError: identical(emailError, _unset) ? this.emailError : emailError as String?,
      otpCode: otpCode ?? this.otpCode,
      password: password ?? this.password,
      passwordError: identical(passwordError, _unset)
          ? this.passwordError
          : passwordError as String?,
      passwordRequirements: passwordRequirements ?? this.passwordRequirements,
      strength: strength ?? this.strength,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
