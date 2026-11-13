class OtpUiState {
  const OtpUiState({
    this.otp = '',
    this.resendCooldown = 30,
    this.resendCount = 0,
    this.isResendCount = false,
    this.isSending = false,
    this.isLoading = false,
  });

  final String otp;
  final int resendCooldown;
  final int resendCount;
  final bool isResendCount;
  final bool isSending;
  final bool isLoading;

  OtpUiState copyWith({
    String? otp,
    int? resendCooldown,
    int? resendCount,
    bool? isResendCount,
    bool? isSending,
    bool? isLoading,
  }) {
    return OtpUiState(
      otp: otp ?? this.otp,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      resendCount: resendCount ?? this.resendCount,
      isResendCount: isResendCount ?? this.isResendCount,
      isSending: isSending ?? this.isSending,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
