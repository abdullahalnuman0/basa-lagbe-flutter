import '../../../core/network/api_result.dart';
import '../../../data/repository/auth_repository.dart';
import '../auth_event.dart';
import '../base_auth_view_model.dart';
import '../signup/password_requirements.dart';
import 'forget_pwd_step.dart';
import 'forget_pwd_ui_state.dart';

final _emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

class ForgetPwdViewModel extends BaseAuthViewModel<ForgetPwdUiState> {
  ForgetPwdViewModel(this._repo) : super(const ForgetPwdUiState());

  final AuthRepository _repo;

  // --- email step ---
  void onEmailChange(String value) => state = state.copyWith(email: value.trim(), emailError: null);

  Future<bool> _validateEmail() async {
    final email = state.email.trim();
    String? emailError;

    if (!_emailRegex.hasMatch(email)) emailError = 'Enter a valid email address.';

    // this also sends the reset code when the account exists
    if (emailError == null) {
      if (await _repo.forgotPassword(email) case ApiError(:final message)) {
        emailError = message;
      }
    }

    state = state.copyWith(emailError: emailError);
    return emailError == null;
  }

  // --- password step ---
  void changeEmail() {
    state = state.copyWith(email: '');
    onGoBack();
  }

  void onOtpChange(String value) => state = state.copyWith(otpCode: value);

  void onPasswordChange(String value) {
    final pwd = value.trim();
    final requirements = PasswordRequirements.of(pwd);
    state = state.copyWith(
      password: pwd,
      passwordError: null,
      passwordRequirements: requirements,
      strength: calculatePasswordStrength(requirements, pwd),
    );
  }

  bool validatePassword() {
    if (!state.passwordRequirements.isValid) {
      state = state.copyWith(passwordError: passwordMessage(state.passwordRequirements));
      return false;
    }
    return true;
  }

  // --- navigation ---
  Future<void> onGoNext() async {
    state = state.copyWith(isLoading: true);

    final current = state.currentStep;
    final valid = switch (current) {
      ForgetPwdStep.email => await _validateEmail(),
      ForgetPwdStep.password => validatePassword(),
    };

    if (!valid) {
      state = state.copyWith(isLoading: false);
      return;
    }

    if (current == ForgetPwdStep.email) {
      state = state.copyWith(
        currentStep: ForgetPwdStep.password,
        isNavForward: true,
        isLoading: false,
      );
      return;
    }

    switch (await _repo.resetPassword(state.email, state.otpCode, state.password)) {
      case ApiError(:final message):
        emit(Toast(message));
      case ApiSuccess():
        emit(const Toast('Password changed — please log in'));
        emit(const GoLogin());
    }

    state = state.copyWith(isLoading: false);
  }

  void onGoBack() {
    state = state.copyWith(currentStep: ForgetPwdStep.email, isNavForward: false);
  }
}
