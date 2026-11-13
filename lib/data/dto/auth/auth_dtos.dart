import '../../../domain/enums/gender.dart';
import '../../common/json.dart';
import '../../enums/enums.dart';
import '../user/user_response.dart';

class AuthResponse {
  const AuthResponse({
    this.accessToken = '',
    this.refreshToken = '',
    this.tokenType,
    this.user = const UserResponse(),
  });

  final String accessToken;
  final String refreshToken;
  final String? tokenType;
  final UserResponse user;

  factory AuthResponse.fromJson(Json json) => AuthResponse(
    accessToken: asString(json['accessToken']),
    refreshToken: asString(json['refreshToken']),
    tokenType: asStringOrNull(json['tokenType']),
    user: json['user'] is Map
        ? UserResponse.fromJson(Json.from(json['user'] as Map))
        : const UserResponse(),
  );
}

class EmailRequest {
  const EmailRequest(this.email);

  final String email;

  Json toJson() => {'email': email};
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Json toJson() => {'email': email, 'password': password};
}

class MessageResponse {
  const MessageResponse(this.message);

  final String? message;

  factory MessageResponse.fromJson(Object? json) =>
      MessageResponse(json is Map ? asStringOrNull(json['message']) : null);
}

class OtpVerifyRequest {
  const OtpVerifyRequest({required this.email, required this.code});

  final String email;
  final String code;

  Json toJson() => {'email': email, 'code': code};
}

class PasswordResetRequest {
  const PasswordResetRequest({required this.email, required this.code, required this.newPassword});

  final String email;
  final String code;
  final String newPassword;

  Json toJson() => {'email': email, 'code': code, 'newPassword': newPassword};
}

class RefreshTokenRequest {
  const RefreshTokenRequest(this.refreshToken);

  final String refreshToken;

  Json toJson() => {'refreshToken': refreshToken};
}

class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.role,
    this.division,
    this.district,
    this.area,
    this.institution,
    this.termsAccepted = false,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final Gender gender;
  final Role role;
  final String? division;
  final String? district;
  final String? area;
  final String? institution;
  final bool termsAccepted;

  Json toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'gender': gender.name,
    'role': role.name,
    'division': division,
    'district': district,
    'area': area,
    'institution': institution,
    'termsAccepted': termsAccepted,
  };
}
