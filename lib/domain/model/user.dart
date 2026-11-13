import '../../data/common/json.dart';
import '../../data/dto/user/user_response.dart';
import '../../data/enums/enums.dart';
import '../enums/gender.dart';

class User {
  User({
    this.id = 0,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.roles = const [],
    this.gender = Gender.MALE,
    this.status = UserStatus.ACTIVE,
    this.emailVerified = false,
    this.division,
    this.district,
    this.area,
    this.institution,
    this.avatarUrl,
    DateTime? createdAt,
    this.suspensionEndAt,
    this.suspensionReason,
    this.deletionScheduledAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final List<Role> roles;
  final Gender gender;
  final UserStatus status;
  final bool emailVerified;
  final String? division;
  final String? district;
  final String? area;
  final String? institution;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? suspensionEndAt;
  final String? suspensionReason;
  final DateTime? deletionScheduledAt;

  bool get isOwner => roles.contains(Role.OWNER);

  bool get isTenant => roles.contains(Role.TENANT);

  UserResponse toData() => UserResponse(
    id: id,
    fullName: fullName,
    email: email,
    phone: phone,
    roles: roles.map((r) => r.name).toList(),
    gender: gender.name,
    status: status.name,
    emailVerified: emailVerified,
    division: division,
    district: district,
    area: area,
    institution: institution,
    avatarUrl: avatarUrl,
    createdAt: instantToString(createdAt),
    suspensionEndAt: suspensionEndAt == null ? null : instantToString(suspensionEndAt!),
    suspensionReason: suspensionReason,
    deletionScheduledAt: deletionScheduledAt == null ? null : instantToString(deletionScheduledAt!),
  );
}
