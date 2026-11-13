import '../../../domain/enums/gender.dart';
import '../../../domain/enums/user_role.dart';
import 'password_requirements.dart';
import 'password_strength.dart';
import 'signup_step.dart';

class SignupUiState {
  const SignupUiState({
    this.currentStep = SignupStep.roleSelection,
    this.isNavigatingForward = true,
    this.selectedRole,
    this.fullName = '',
    this.fullNameError,
    this.email = '',
    this.emailError,
    this.phone = '',
    this.phoneError,
    this.gender,
    this.genderError,
    this.institution = '',
    this.isCustomInstitution = false,
    this.institutionError,
    this.division = '',
    this.divisionError,
    this.district = '',
    this.districtError,
    this.area = '',
    this.areaError,
    this.password = '',
    this.passwordError,
    this.confirmPassword = '',
    this.confirmPasswordError,
    this.passwordRequirements = const PasswordRequirements(),
    this.strength = PasswordStrength.empty,
    this.isAcceptTermsAndCondition = false,
    this.termsError,
    this.isLoading = false,
  });

  final SignupStep currentStep;
  final bool isNavigatingForward;

  // --- role ---
  final UserRole? selectedRole;

  // --- basic info ---
  final String fullName;
  final String? fullNameError;
  final String email;
  final String? emailError;
  final String phone;
  final String? phoneError;

  // --- about you ---
  final Gender? gender;
  final String? genderError;
  final String institution;
  final bool isCustomInstitution;
  final String? institutionError;

  // --- location ---
  final String division;
  final String? divisionError;
  final String district;
  final String? districtError;
  final String area;
  final String? areaError;

  // --- security ---
  final String password;
  final String? passwordError;
  final String confirmPassword;
  final String? confirmPasswordError;
  final PasswordRequirements passwordRequirements;
  final PasswordStrength strength;
  final bool isAcceptTermsAndCondition;
  final String? termsError;

  final bool isLoading;

  static const _unset = Object();

  SignupUiState copyWith({
    SignupStep? currentStep,
    bool? isNavigatingForward,
    UserRole? selectedRole,
    String? fullName,
    Object? fullNameError = _unset,
    String? email,
    Object? emailError = _unset,
    String? phone,
    Object? phoneError = _unset,
    Gender? gender,
    Object? genderError = _unset,
    String? institution,
    bool? isCustomInstitution,
    Object? institutionError = _unset,
    String? division,
    Object? divisionError = _unset,
    String? district,
    Object? districtError = _unset,
    String? area,
    Object? areaError = _unset,
    String? password,
    Object? passwordError = _unset,
    String? confirmPassword,
    Object? confirmPasswordError = _unset,
    PasswordRequirements? passwordRequirements,
    PasswordStrength? strength,
    bool? isAcceptTermsAndCondition,
    Object? termsError = _unset,
    bool? isLoading,
  }) {
    String? pick(Object? value, String? current) =>
        identical(value, _unset) ? current : value as String?;

    return SignupUiState(
      currentStep: currentStep ?? this.currentStep,
      isNavigatingForward: isNavigatingForward ?? this.isNavigatingForward,
      selectedRole: selectedRole ?? this.selectedRole,
      fullName: fullName ?? this.fullName,
      fullNameError: pick(fullNameError, this.fullNameError),
      email: email ?? this.email,
      emailError: pick(emailError, this.emailError),
      phone: phone ?? this.phone,
      phoneError: pick(phoneError, this.phoneError),
      gender: gender ?? this.gender,
      genderError: pick(genderError, this.genderError),
      institution: institution ?? this.institution,
      isCustomInstitution: isCustomInstitution ?? this.isCustomInstitution,
      institutionError: pick(institutionError, this.institutionError),
      division: division ?? this.division,
      divisionError: pick(divisionError, this.divisionError),
      district: district ?? this.district,
      districtError: pick(districtError, this.districtError),
      area: area ?? this.area,
      areaError: pick(areaError, this.areaError),
      password: password ?? this.password,
      passwordError: pick(passwordError, this.passwordError),
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordError: pick(confirmPasswordError, this.confirmPasswordError),
      passwordRequirements: passwordRequirements ?? this.passwordRequirements,
      strength: strength ?? this.strength,
      isAcceptTermsAndCondition: isAcceptTermsAndCondition ?? this.isAcceptTermsAndCondition,
      termsError: pick(termsError, this.termsError),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
