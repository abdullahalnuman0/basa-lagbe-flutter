class SigningUiState {
  const SigningUiState({this.email = '', this.password = '', this.error, this.isLoading = false});

  final String email;
  final String password;
  final String? error;
  final bool isLoading;

  static const _unset = Object();

  SigningUiState copyWith({
    String? email,
    String? password,
    Object? error = _unset,
    bool? isLoading,
  }) {
    return SigningUiState(
      email: email ?? this.email,
      password: password ?? this.password,
      error: identical(error, _unset) ? this.error : error as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
