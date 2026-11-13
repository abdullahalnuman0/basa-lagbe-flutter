enum PasswordStrength {
  empty('', 0),
  weak('Weak', 0.25),
  fair('Fair', 0.5),
  medium('Medium', 0.75),
  strong('Strong', 1);

  const PasswordStrength(this.label, this.score);

  final String label;
  final double score;
}
