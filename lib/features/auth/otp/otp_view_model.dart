import 'dart:async';
import 'dart:math' as math;

import '../../../core/network/api_result.dart';
import '../../../data/repository/auth_repository.dart';
import '../auth_event.dart';
import '../base_auth_view_model.dart';
import 'otp_ui_state.dart';

class OtpViewModel extends BaseAuthViewModel<OtpUiState> {
  OtpViewModel(this._repo) : super(const OtpUiState());

  final AuthRepository _repo;
  Timer? _resendTimer;

  void onOtpChange(String value) => state = state.copyWith(otp: value);

  Future<void> resend(String email, bool recover) async {
    if (state.isLoading || state.isResendCount) return;

    _startResendCount();
    state = state.copyWith(isLoading: true, isSending: true);

    switch (await _repo.resendOtp(email)) {
      case ApiError(:final message):
        emit(Toast(message));
      case ApiSuccess(:final data):
        emit(Toast(data.message ?? 'A new code has been sent.'));
    }

    state = state.copyWith(isLoading: false, isSending: false);
  }

  void _startResendCount() {
    _resendTimer?.cancel();

    state = state.copyWith(
      resendCooldown: 30 + 15 * state.resendCount,
      isResendCount: true,
      resendCount: state.resendCount + 1,
    );

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = math.max(state.resendCooldown - 1, 0);
      state = state.copyWith(resendCooldown: left, isResendCount: left > 0);
      if (left == 0) timer.cancel();
    });
  }

  Future<void> verifyOtp(String email, bool recover) async {
    state = state.copyWith(isLoading: true);

    // a successful verify saves the session and the app moves on by itself
    if (await _repo.verifyOtp(email, state.otp) case ApiError(:final message)) {
      emit(Toast(message));
    }

    state = state.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
