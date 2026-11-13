import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/data/dto/notification/notification_response.dart';
import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/dto/room/room_dtos.dart';
import 'package:messseat/data/dto/tenant/tenant_dtos.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/domain/enums/gender.dart';
import 'package:messseat/domain/enums/property_gender.dart';
import 'package:messseat/domain/enums/property_type.dart';

Map<String, dynamic> roomJson({int id = 7}) => {
  'totalViews': 12,
  'availableSeats': 2,
  'deposit': 1000,
  'id': id,
  'images': ['rooms/a.jpg', 'rooms/b.jpg'],
  'rent': 4500,
  'roomHeight': 10,
  'roomNumber': '101',
  'roomWidth': 12,
  'type': 'DOUBLE',
  'createdAt': '2026-01-05T10:00:00Z',
};

void main() {
  group('UserResponse', () {
    test('maps to the domain user', () {
      final user = UserResponse.fromJson({
        'id': 3,
        'fullName': 'Rahim Uddin',
        'email': 'rahim@mail.com',
        'phone': '01700000000',
        'roles': ['OWNER'],
        'gender': 'FEMALE',
        'status': 'SUSPENDED',
        'emailVerified': true,
        'createdAt': '2026-02-01T08:30:00Z',
        'suspensionEndAt': '2026-03-01T00:00:00Z',
      }).toDomain();

      expect(user.id, 3);
      expect(user.isOwner, isTrue);
      expect(user.isTenant, isFalse);
      expect(user.gender, Gender.FEMALE);
      expect(user.status, UserStatus.SUSPENDED);
      expect(user.createdAt, DateTime.utc(2026, 2, 1, 8, 30));
      expect(user.suspensionEndAt, DateTime.utc(2026, 3, 1));
      expect(user.deletionScheduledAt, isNull);
    });

    test('survives a json round trip', () {
      const original = UserResponse(id: 9, fullName: 'Karim', roles: ['TENANT']);
      final copy = UserResponse.fromJson(original.toJson());
      expect(copy.id, 9);
      expect(copy.fullName, 'Karim');
      expect(copy.roles, ['TENANT']);
    });

    test('falls back to defaults on missing fields', () {
      final user = UserResponse.fromJson({}).toDomain();
      expect(user.gender, Gender.MALE);
      expect(user.status, UserStatus.ACTIVE);
      expect(user.roles, isEmpty);
    });
  });

  test('AuthResponse reads tokens and nested user', () {
    final auth = AuthResponse.fromJson({
      'accessToken': 'a',
      'refreshToken': 'r',
      'user': {
        'id': 1,
        'roles': ['TENANT'],
      },
    });
    expect(auth.accessToken, 'a');
    expect(auth.refreshToken, 'r');
    expect(auth.user.id, 1);
  });

  test('RegisterRequest serialises enums by name', () {
    const req = RegisterRequest(
      fullName: 'A',
      email: 'a@b.c',
      phone: '017',
      password: 'Secret#1',
      gender: Gender.MALE,
      role: Role.OWNER,
      termsAccepted: true,
    );
    final json = req.toJson();
    expect(json['gender'], 'MALE');
    expect(json['role'], 'OWNER');
    expect(json['termsAccepted'], true);
    expect(json.containsKey('division'), isTrue);
  });

  group('PropertyResponse', () {
    test('parses nested rooms and enums', () {
      final property = PropertyResponse.fromJson({
        'id': 5,
        'title': 'Green Mess',
        'description': 'Near campus',
        'approved': false,
        'division': 'Dhaka',
        'district': 'Dhaka',
        'area': 'Mirpur 10',
        'address': 'Road 3',
        'contactNumber': '01800000000',
        'gender': 'MALE',
        'type': 'MESS',
        'institutionNearby': 'DU',
        'facilities': ['WiFi', 'Lift'],
        'rooms': [roomJson()],
        'createdAt': '2026-01-01T00:00:00Z',
      });

      expect(property.type, PropertyType.MESS);
      expect(property.gender, PropertyGender.MALE);
      expect(property.rooms.single.type, RoomType.DOUBLE);
      expect(property.rooms.single.images, hasLength(2));
      expect(property.facilities, ['WiFi', 'Lift']);
    });

    test('round trips through toJson', () {
      final property = PropertyResponse.fromJson({
        'id': 5,
        'title': 'T',
        'gender': 'ANY',
        'type': 'FLAT',
        'rooms': [roomJson(id: 1), roomJson(id: 2)],
        'createdAt': '2026-01-01T00:00:00Z',
      });
      final copy = PropertyResponse.fromJson(property.toJson());
      expect(copy.rooms.map((r) => r.id), [1, 2]);
      expect(copy.type, PropertyType.FLAT);
      expect(copy.createdAt, property.createdAt);
    });
  });

  test('RoomResponse converts to the domain room and back', () {
    final room = RoomResponse.fromJson(roomJson()).toRoom();
    expect(room.rent, 4500);
    expect(room.type, RoomType.DOUBLE);
    final back = room.toRoomResponse();
    expect(back.toJson()['type'], 'DOUBLE');
    expect(back.roomNumber, '101');
  });

  test('RoomTenantResponse parses enums', () {
    final room = RoomTenantResponse.fromJson({
      'ownerId': 1,
      'ownerName': 'Owner',
      'gender': 'FEMALE',
      'propertyType': 'HOSTEL',
      'roomType': 'SINGLE',
      'roomId': 44,
      'images': [],
      'facilities': [],
    });
    expect(room.gender, PropertyGender.FEMALE);
    expect(room.propertyType, PropertyType.HOSTEL);
    expect(room.roomType, RoomType.SINGLE);
    expect(room.ownerAvatarUrl, isNull);
  });

  test('PageResponse reads content and paging flags', () {
    final page = PageResponse.fromJson({
      'content': [
        {'id': 1, 'title': 'Hello', 'refType': 'CHAT', 'refId': 9},
        {'id': 2, 'title': 'Bye', 'refType': 'SOMETHING_NEW'},
      ],
      'page': 0,
      'size': 20,
      'last': false,
    }, NotificationResponse.fromJson);

    expect(page.content, hasLength(2));
    expect(page.content.first.refType, NotyRefType.CHAT);
    expect(page.content.first.refId, 9);
    expect(page.content.last.refType, isNull);
    expect(page.last, isFalse);
  });

  test('ChatMessageResponse defaults to text', () {
    final msg = ChatMessageResponse.fromJson({'id': 1, 'content': 'hi'});
    expect(msg.type, MessageType.TEXT);
    final image = ChatMessageResponse.fromJson({'id': 2, 'type': 'IMAGE', 'attachmentUrl': 'k'});
    expect(image.type, MessageType.IMAGE);
  });
}
