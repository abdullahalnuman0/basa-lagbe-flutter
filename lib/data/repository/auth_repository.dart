import '../../core/data/session_manager.dart';
import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../api/auth_api.dart';
import '../dto/auth/auth_dtos.dart';
import '../dto/user/user_response.dart';

class AuthRepository {
  AuthRepository(this._api, this._session);

  final AuthApi _api;
  final SessionManager _session;

  Future<ApiResult<void>> verifyEmail(EmailRequest body) =>
      safeApiCall(() => _api.verifyEmail(body));

  Future<ApiResult<UserResponse>> register(RegisterRequest req) =>
      safeApiCall(() => _api.register(req));

  Future<ApiResult<AuthResponse>> verifyOtp(String email, String code) => safeApiCall(() async {
    final auth = await _api.verifyOtp(OtpVerifyRequest(email: email, code: code));
    await _session.saveSession(auth);
    return auth;
  });

  Future<ApiResult<MessageResponse>> resendOtp(String email) =>
      safeApiCall(() => _api.resendOtp(EmailRequest(email)));

  Future<ApiResult<AuthResponse>> login(String email, String password) => safeApiCall(() async {
    final auth = await _api.login(LoginRequest(email: email, password: password));
    await _session.saveSession(auth);
    return auth;
  });

  Future<ApiResult<MessageResponse>> forgotPassword(String email) =>
      safeApiCall(() => _api.forgotPassword(EmailRequest(email)));

  Future<ApiResult<MessageResponse>> resetPassword(String email, String code, String newPwd) =>
      safeApiCall(
        () =>
            _api.resetPassword(PasswordResetRequest(email: email, code: code, newPassword: newPwd)),
      );

  Future<void> logout() async {
    try {
      final token = _session.refreshToken();
      if (token != null) await _api.logout(RefreshTokenRequest(token));
    } catch (_) {}
    await _session.clear();
  }
}
