import '../../../core/network/api_result.dart';
import '../../../data/dto/auth/auth_dtos.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../domain/enums/gender.dart';
import '../../../domain/enums/user_role.dart';
import '../auth_event.dart';
import '../base_auth_view_model.dart';
import 'password_requirements.dart';
import 'signup_step.dart';
import 'signup_ui_state.dart';

final _phoneRegex = RegExp(r'^01[3-9]\d{8}$');
final _emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

class SignupViewModel extends BaseAuthViewModel<SignupUiState> {
  SignupViewModel(this._repo) : super(const SignupUiState());

  final AuthRepository _repo;

  // --- role ---
  void onRoleSelected(UserRole role) => state = state.copyWith(selectedRole: role);

  bool _canContinueFromRole() => state.selectedRole != null;

  // --- basic info ---
  void onFullNameChange(String value) =>
      state = state.copyWith(fullName: value, fullNameError: null);

  void onEmailChange(String value) => state = state.copyWith(email: value, emailError: null);

  void onPhoneChange(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(
      phone: digits.length > 11 ? digits.substring(0, 11) : digits,
      phoneError: null,
    );
  }

  Future<bool> _validateBasicInfo() async {
    final email = state.email.trim();
    String? nameError;
    String? emailError;
    String? phoneError;

    if (state.fullName.trim().isEmpty) nameError = 'Please enter your full name.';

    if (!_emailRegex.hasMatch(email)) emailError = 'Enter a valid email address.';

    // make sure the email isn't already taken
    if (emailError == null) {
      if (await _repo.verifyEmail(EmailRequest(email)) case ApiError(:final message)) {
        emailError = message;
      }
    }

    if (!_phoneRegex.hasMatch(state.phone)) phoneError = 'Enter a valid phone number.';

    state = state.copyWith(
      fullNameError: nameError,
      emailError: emailError,
      phoneError: phoneError,
    );
    return nameError == null && emailError == null && phoneError == null;
  }

  // --- about you ---
  void onGenderSelected(Gender gender) => state = state.copyWith(gender: gender, genderError: null);

  void onInstitutionChange(String value) =>
      state = state.copyWith(institution: value, institutionError: null);

  void onInstitutionNotListedToggle(bool value) =>
      state = state.copyWith(isCustomInstitution: value);

  bool _validateAboutYou() {
    final genderError = state.gender == null ? 'Please select your gender' : null;
    state = state.copyWith(genderError: genderError);
    return genderError == null;
  }

  // --- location ---
  void onDivisionSelected(String value) =>
      state = state.copyWith(division: value, divisionError: null);

  void onDistrictSelected(String value) =>
      state = state.copyWith(district: value, districtError: null);

  void onAreaSelected(String value) => state = state.copyWith(area: value, areaError: null);

  bool _validateLocation() {
    final divError = state.division.isEmpty ? 'Please select your division.' : null;
    final disError = state.district.isEmpty ? 'Please select your district.' : null;
    final areaError = state.area.isEmpty ? 'Please enter your area.' : null;

    state = state.copyWith(divisionError: divError, districtError: disError, areaError: areaError);
    return divError == null && disError == null && areaError == null;
  }

  // --- security ---
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

  void onConfirmPassChange(String value) =>
      state = state.copyWith(confirmPassword: value.trim(), confirmPasswordError: null);

  void onTermsToggle(bool value) =>
      state = state.copyWith(isAcceptTermsAndCondition: value, termsError: null);

  bool _validateSecurity() {
    if (!state.passwordRequirements.isValid) {
      state = state.copyWith(passwordError: passwordMessage(state.passwordRequirements));
      return false;
    }

    String? confirmPassError;
    if (state.confirmPassword.isEmpty) {
      confirmPassError = 'Please re-enter your password.';
    } else if (state.password != state.confirmPassword) {
      confirmPassError = "Passwords don't match";
    }

    final termsError = state.isAcceptTermsAndCondition
        ? null
        : 'Please agree to the Terms & Conditions';

    state = state.copyWith(confirmPasswordError: confirmPassError, termsError: termsError);
    return confirmPassError == null && termsError == null;
  }

  // --- navigation ---
  Future<void> onGoNext() async {
    state = state.copyWith(isLoading: true);

    final current = state.currentStep;
    final valid = switch (current) {
      SignupStep.roleSelection => _canContinueFromRole(),
      SignupStep.basicInfo => await _validateBasicInfo(),
      SignupStep.aboutYou => _validateAboutYou(),
      SignupStep.location => _validateLocation(),
      SignupStep.security => _validateSecurity(),
    };

    if (!valid) {
      state = state.copyWith(isLoading: false);
      return;
    }

    if (current == SignupStep.security) {
      await _register();
      state = state.copyWith(isLoading: false);
      return;
    }

    final next = switch (current) {
      SignupStep.roleSelection => SignupStep.basicInfo,
      SignupStep.basicInfo => SignupStep.aboutYou,
      SignupStep.aboutYou => SignupStep.location,
      SignupStep.location || SignupStep.security => SignupStep.security,
    };
    state = state.copyWith(currentStep: next, isNavigatingForward: true, isLoading: false);
  }

  Future<void> _register() async {
    final email = state.email.trim();
    final req = RegisterRequest(
      role: state.selectedRole!.toData(),
      fullName: state.fullName.trim(),
      email: email,
      phone: state.phone,
      gender: state.gender!,
      institution: state.institution,
      division: state.division,
      district: state.district,
      area: state.area,
      password: state.password.trim(),
      termsAccepted: state.isAcceptTermsAndCondition,
    );

    switch (await _repo.register(req)) {
      case ApiError(:final message):
        emit(Toast(message, isError: true));
      case ApiSuccess():
        emit(GoVerify(email));
    }
  }

  void onGoBack() {
    final previous = switch (state.currentStep) {
      SignupStep.basicInfo => SignupStep.roleSelection,
      SignupStep.aboutYou => SignupStep.basicInfo,
      SignupStep.location => SignupStep.aboutYou,
      SignupStep.security => SignupStep.location,
      SignupStep.roleSelection => SignupStep.roleSelection,
    };
    state = state.copyWith(currentStep: previous, isNavigatingForward: false);
  }
}
