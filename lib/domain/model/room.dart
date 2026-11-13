import '../../data/dto/room/room_dtos.dart';
import '../../data/enums/enums.dart';

class Room {
  Room({
    this.totalViews = 0,
    this.availableSeats = 0,
    this.deposit = 0,
    this.id = 0,
    this.images = const [],
    this.rent = 0,
    this.roomHeight = 0,
    this.roomNumber = '',
    this.roomWidth = 0,
    this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final int totalViews;
  final int availableSeats;
  final int deposit;
  final int id;
  final List<String> images;
  final int rent;
  final int roomHeight;
  final String roomNumber;
  final int roomWidth;
  final RoomType? type;
  final DateTime createdAt;

  Room copyWith({
    int? totalViews,
    int? availableSeats,
    int? deposit,
    int? id,
    List<String>? images,
    int? rent,
    int? roomHeight,
    String? roomNumber,
    int? roomWidth,
    RoomType? type,
    DateTime? createdAt,
  }) => Room(
    totalViews: totalViews ?? this.totalViews,
    availableSeats: availableSeats ?? this.availableSeats,
    deposit: deposit ?? this.deposit,
    id: id ?? this.id,
    images: images ?? this.images,
    rent: rent ?? this.rent,
    roomHeight: roomHeight ?? this.roomHeight,
    roomNumber: roomNumber ?? this.roomNumber,
    roomWidth: roomWidth ?? this.roomWidth,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );

  RoomResponse toRoomResponse() => RoomResponse(
    totalViews: totalViews,
    availableSeats: availableSeats,
    deposit: deposit,
    id: id,
    images: images,
    rent: rent,
    roomHeight: roomHeight,
    roomNumber: roomNumber,
    roomWidth: roomWidth,
    type: type!,
    createdAt: createdAt,
  );
}
