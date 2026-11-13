import 'package:dio/dio.dart';

import '../dto/auth/auth_dtos.dart';
import '../dto/user/user_response.dart';

class UserApi {
  UserApi(this._dio);

  final Dio _dio;

  Future<MessageResponse> updateFcmToken(FcmTokenRequest body) async {
    final res = await _dio.put<dynamic>('users/me/fcm-token', data: body.toJson());
    return MessageResponse.fromJson(res.data);
  }

  Future<MessageResponse> heartbeat() async {
    final res = await _dio.post<dynamic>('users/me/heartbeat');
    return MessageResponse.fromJson(res.data);
  }
}
