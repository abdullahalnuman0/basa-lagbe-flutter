import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/dto/room/room_dtos.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/domain/enums/property_gender.dart';
import 'package:messseat/domain/enums/property_type.dart';

RoomResponse room({
  int id = 1,
  String number = '101',
  int seats = 2,
  int rent = 3000,
  List<String> images = const [],
}) {
  return RoomResponse(
    availableSeats: seats,
    deposit: 1000,
    id: id,
    images: images,
    rent: rent,
    roomHeight: 10,
    roomNumber: number,
    roomWidth: 12,
    type: RoomType.DOUBLE,
    createdAt: DateTime(2025, 1, 1),
  );
}

PropertyResponse property({
  int id = 1,
  bool approved = true,
  List<RoomResponse> rooms = const [],
  String description = 'A quiet place near campus.',
  List<String> facilities = const ['WiFi', 'Laundry'],
}) {
  return PropertyResponse(
    id: id,
    title: 'Green Villa',
    description: description,
    approved: approved,
    division: 'Dhaka',
    district: 'Dhaka',
    area: 'Mirpur',
    address: 'House 12, Road 3',
    contactNumber: '01700000000',
    gender: PropertyGender.MALE,
    type: PropertyType.MESS,
    institutionNearby: 'Dhaka University',
    facilities: facilities,
    rooms: rooms,
    createdAt: DateTime(2025, 1, 1),
  );
}
