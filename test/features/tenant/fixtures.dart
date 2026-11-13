import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/tenant/tenant_dtos.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/data/repository/chat_repository.dart';
import 'package:messseat/data/repository/tenant_repository.dart';
import 'package:messseat/domain/enums/property_gender.dart';
import 'package:messseat/domain/enums/property_type.dart';
import 'package:mocktail/mocktail.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

RoomTenantResponse room({
  int id = 1,
  String title = 'Sunny room near DU',
  List<String> images = const [],
  String description = '',
}) {
  return RoomTenantResponse(
    ownerId: 9,
    ownerName: 'Karim Hossain',
    address: 'Road 5, Dhanmondi, Dhaka',
    area: 'Dhanmondi',
    availableSeats: 2,
    contactNumber: '01700000000',
    createdAt: '2026-01-05T10:00:00Z',
    deposit: 2000,
    description: description,
    district: 'Dhaka',
    division: 'Dhaka',
    facilities: const ['Wi-Fi', 'Kitchen'],
    gender: PropertyGender.MALE,
    images: images,
    institutionNearby: 'University of Dhaka',
    propertyId: 4,
    propertyType: PropertyType.MESS,
    rent: 4500,
    roomHeight: 10,
    roomId: id,
    roomNumber: 'A-$id',
    roomType: RoomType.DOUBLE,
    roomWidth: 12,
    title: title,
  );
}

PageResponse<RoomTenantResponse> page(List<RoomTenantResponse> rooms, {bool last = true}) =>
    PageResponse(content: rooms, size: 10, last: last);
