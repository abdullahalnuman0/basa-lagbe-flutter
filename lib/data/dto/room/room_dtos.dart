import '../../../domain/model/room.dart';
import '../../common/json.dart';
import '../../enums/enums.dart';

class RoomAvailabilityRequest {
  const RoomAvailabilityRequest({required this.roomId, required this.availableSeats});

  final int roomId;
  final int availableSeats;

  Json toJson() => {'roomId': roomId, 'availableSeats': availableSeats};
}

class RoomRequest {
  const RoomRequest({
    required this.availableSeats,
    this.deposit = 0,
    required this.images,
    required this.rent,
    required this.roomHeight,
    required this.roomNumber,
    required this.roomWidth,
    required this.type,
  });

  final int availableSeats;
  final int deposit;
  final List<String> images;
  final int rent;
  final int roomHeight;
  final String roomNumber;
  final int roomWidth;
  final RoomType type;

  Json toJson() => {
    'availableSeats': availableSeats,
    'deposit': deposit,
    'images': images,
    'rent': rent,
    'roomHeight': roomHeight,
    'roomNumber': roomNumber,
    'roomWidth': roomWidth,
    'type': type.name,
  };

  Room toDomain() => Room(
    availableSeats: availableSeats,
    deposit: deposit,
    images: images,
    rent: rent,
    roomHeight: roomHeight,
    roomNumber: roomNumber,
    roomWidth: roomWidth,
    type: type,
  );
}

class RoomResponse {
  const RoomResponse({
    this.totalViews = 0,
    required this.availableSeats,
    required this.deposit,
    required this.id,
    required this.images,
    required this.rent,
    required this.roomHeight,
    required this.roomNumber,
    required this.roomWidth,
    required this.type,
    required this.createdAt,
  });

  final int totalViews;
  final int availableSeats;
  final int deposit;
  final int id;
  final List<String> images;
  final int rent;
  final int roomHeight;
  final String roomNumber;
  final int roomWidth;
  final RoomType type;
  final DateTime createdAt;

  factory RoomResponse.fromJson(Json json) => RoomResponse(
    totalViews: asInt(json['totalViews']),
    availableSeats: asInt(json['availableSeats']),
    deposit: asInt(json['deposit']),
    id: asInt(json['id']),
    images: asStringList(json['images']),
    rent: asInt(json['rent']),
    roomHeight: asInt(json['roomHeight']),
    roomNumber: asString(json['roomNumber']),
    roomWidth: asInt(json['roomWidth']),
    type: enumByName(RoomType.values, json['type'], RoomType.SINGLE),
    createdAt: parseInstant(json['createdAt']),
  );

  Json toJson() => {
    'totalViews': totalViews,
    'availableSeats': availableSeats,
    'deposit': deposit,
    'id': id,
    'images': images,
    'rent': rent,
    'roomHeight': roomHeight,
    'roomNumber': roomNumber,
    'roomWidth': roomWidth,
    'type': type.name,
    'createdAt': instantToString(createdAt),
  };

  RoomResponse copyWith({int? availableSeats}) => RoomResponse(
    totalViews: totalViews,
    availableSeats: availableSeats ?? this.availableSeats,
    deposit: deposit,
    id: id,
    images: images,
    rent: rent,
    roomHeight: roomHeight,
    roomNumber: roomNumber,
    roomWidth: roomWidth,
    type: type,
    createdAt: createdAt,
  );

  Room toRoom() => Room(
    totalViews: totalViews,
    availableSeats: availableSeats,
    deposit: deposit,
    id: id,
    images: images,
    rent: rent,
    roomHeight: roomHeight,
    roomNumber: roomNumber,
    roomWidth: roomWidth,
    type: type,
    createdAt: createdAt,
  );
}
