import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../api/user_api.dart';
import '../dto/user/user_response.dart';

class UserRepository {
  UserRepository(this._api);

  final UserApi _api;

  Future<ApiResult<void>> updateFcmToken(String token) =>
      safeApiCall(() => _api.updateFcmToken(FcmTokenRequest(token)));

  Future<void> heartbeat() async {
    try {
      await _api.heartbeat();
    } catch (_) {}
  }
}
