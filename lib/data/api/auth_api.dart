import 'package:dio/dio.dart';

import '../common/json.dart';
import '../dto/auth/auth_dtos.dart';
import '../dto/user/user_response.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<void> verifyEmail(EmailRequest body) async {
    await _dio.post<dynamic>('auth/email-verify', data: body.toJson());
  }

  Future<UserResponse> register(RegisterRequest body) async {
    final res = await _dio.post<Json>('auth/register', data: body.toJson());
    return UserResponse.fromJson(res.data!);
  }

  Future<AuthResponse> verifyOtp(OtpVerifyRequest body) async {
    final res = await _dio.post<Json>('auth/verify-otp', data: body.toJson());
    return AuthResponse.fromJson(res.data!);
  }

  Future<MessageResponse> resendOtp(EmailRequest body) async {
    final res = await _dio.post<dynamic>('auth/resend-otp', data: body.toJson());
    return MessageResponse.fromJson(res.data);
  }

  Future<AuthResponse> login(LoginRequest body) async {
    final res = await _dio.post<Json>('auth/login', data: body.toJson());
    return AuthResponse.fromJson(res.data!);
  }

  Future<MessageResponse> forgotPassword(EmailRequest body) async {
    final res = await _dio.post<dynamic>('auth/forgot-password', data: body.toJson());
    return MessageResponse.fromJson(res.data);
  }

  Future<MessageResponse> resetPassword(PasswordResetRequest body) async {
    final res = await _dio.post<dynamic>('auth/reset-password', data: body.toJson());
    return MessageResponse.fromJson(res.data);
  }

  Future<MessageResponse> logout(RefreshTokenRequest body) async {
    final res = await _dio.post<dynamic>('auth/logout', data: body.toJson());
    return MessageResponse.fromJson(res.data);
  }
}
