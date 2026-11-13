import '../../../domain/enums/gender.dart';
import '../../../domain/model/user.dart';
import '../../common/json.dart';
import '../../enums/enums.dart';

class UserResponse {
  const UserResponse({
    this.id = 0,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.roles = const [],
    this.gender = 'MALE',
    this.status = 'ACTIVE',
    this.emailVerified = false,
    this.division,
    this.district,
    this.area,
    this.institution,
    this.avatarUrl,
    this.createdAt,
    this.suspensionEndAt,
    this.suspensionReason,
    this.deletionScheduledAt,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final List<String> roles;
  final String gender;
  final String status;
  final bool emailVerified;
  final String? division;
  final String? district;
  final String? area;
  final String? institution;
  final String? avatarUrl;
  final String? createdAt;
  final String? suspensionEndAt;
  final String? suspensionReason;
  final String? deletionScheduledAt;

  factory UserResponse.fromJson(Json json) => UserResponse(
    id: asInt(json['id']),
    fullName: asString(json['fullName']),
    email: asString(json['email']),
    phone: asString(json['phone']),
    roles: asStringList(json['roles']),
    gender: asString(json['gender'], 'MALE'),
    status: asString(json['status'], 'ACTIVE'),
    emailVerified: asBool(json['emailVerified']),
    division: asStringOrNull(json['division']),
    district: asStringOrNull(json['district']),
    area: asStringOrNull(json['area']),
    institution: asStringOrNull(json['institution']),
    avatarUrl: asStringOrNull(json['avatarUrl']),
    createdAt: asStringOrNull(json['createdAt']),
    suspensionEndAt: asStringOrNull(json['suspensionEndAt']),
    suspensionReason: asStringOrNull(json['suspensionReason']),
    deletionScheduledAt: asStringOrNull(json['deletionScheduledAt']),
  );

  Json toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'roles': roles,
    'gender': gender,
    'status': status,
    'emailVerified': emailVerified,
    'division': division,
    'district': district,
    'area': area,
    'institution': institution,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt,
    'suspensionEndAt': suspensionEndAt,
    'suspensionReason': suspensionReason,
    'deletionScheduledAt': deletionScheduledAt,
  };

  User toDomain() => User(
    id: id,
    fullName: fullName,
    email: email,
    phone: phone,
    roles: roles.map((r) => enumByName(Role.values, r, Role.TENANT)).toList(),
    gender: enumByName(Gender.values, gender, Gender.MALE),
    status: enumByName(UserStatus.values, status, UserStatus.ACTIVE),
    emailVerified: emailVerified,
    division: division,
    district: district,
    area: area,
    institution: institution,
    avatarUrl: avatarUrl,
    createdAt: parseInstant(createdAt),
    suspensionEndAt: suspensionEndAt == null ? null : DateTime.tryParse(suspensionEndAt!),
    suspensionReason: suspensionReason,
    deletionScheduledAt: deletionScheduledAt == null
        ? null
        : DateTime.tryParse(deletionScheduledAt!),
  );
}

class FcmTokenRequest {
  const FcmTokenRequest(this.token);

  final String token;

  Json toJson() => {'token': token};
}
