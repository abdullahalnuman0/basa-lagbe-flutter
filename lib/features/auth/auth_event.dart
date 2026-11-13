sealed class AuthEvent {
  const AuthEvent();
}

final class GoVerify extends AuthEvent {
  const GoVerify(this.email);

  final String email;
}

final class GoRecover extends AuthEvent {
  const GoRecover(this.email);

  final String email;
}

final class GoReset extends AuthEvent {
  const GoReset(this.email);

  final String email;
}

final class GoLogin extends AuthEvent {
  const GoLogin();
}

final class Toast extends AuthEvent {
  const Toast(this.message, {this.isError = false});

  final String message;
  final bool isError;
}
