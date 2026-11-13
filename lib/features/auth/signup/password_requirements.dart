final _upper = RegExp(r'\p{Lu}', unicode: true);
final _digit = RegExp(r'\p{Nd}', unicode: true);
final _special = RegExp(r'[^\p{L}\p{Nd}]', unicode: true);

class PasswordRequirements {
  const PasswordRequirements({
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasNumber = false,
    this.hasSpacialChar = false,
  });

  factory PasswordRequirements.of(String password) => PasswordRequirements(
    hasMinLength: password.length >= 8,
    hasUppercase: password.contains(_upper),
    hasNumber: password.contains(_digit),
    hasSpacialChar: password.contains(_special),
  );

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpacialChar;

  bool get isValid => hasMinLength && hasUppercase && hasNumber && hasSpacialChar;
}
