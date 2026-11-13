import '../../../domain/enums/property_gender.dart';
import '../../../domain/enums/property_type.dart';
import '../../common/json.dart';
import '../../enums/enums.dart';

class RoomTenantResponse {
  const RoomTenantResponse({
    this.ownerAvatarUrl,
    required this.ownerId,
    required this.ownerName,
    required this.address,
    required this.area,
    required this.availableSeats,
    required this.contactNumber,
    required this.createdAt,
    required this.deposit,
    required this.description,
    required this.district,
    required this.division,
    required this.facilities,
    required this.gender,
    required this.images,
    required this.institutionNearby,
    required this.propertyId,
    required this.propertyType,
    required this.rent,
    required this.roomHeight,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.roomWidth,
    required this.title,
  });

  final String? ownerAvatarUrl;
  final int ownerId;
  final String ownerName;
  final String address;
  final String area;
  final int availableSeats;
  final String contactNumber;
  final String createdAt;
  final int deposit;
  final String description;
  final String district;
  final String division;
  final List<String> facilities;
  final PropertyGender gender;
  final List<String> images;
  final String institutionNearby;
  final int propertyId;
  final PropertyType propertyType;
  final int rent;
  final int roomHeight;
  final int roomId;
  final String roomNumber;
  final RoomType roomType;
  final int roomWidth;
  final String title;

  factory RoomTenantResponse.fromJson(Json json) => RoomTenantResponse(
    ownerAvatarUrl: asStringOrNull(json['ownerAvatarUrl']),
    ownerId: asInt(json['ownerId']),
    ownerName: asString(json['ownerName']),
    address: asString(json['address']),
    area: asString(json['area']),
    availableSeats: asInt(json['availableSeats']),
    contactNumber: asString(json['contactNumber']),
    createdAt: asString(json['createdAt']),
    deposit: asInt(json['deposit']),
    description: asString(json['description']),
    district: asString(json['district']),
    division: asString(json['division']),
    facilities: asStringList(json['facilities']),
    gender: enumByName(PropertyGender.values, json['gender'], PropertyGender.ANY),
    images: asStringList(json['images']),
    institutionNearby: asString(json['institutionNearby']),
    propertyId: asInt(json['propertyId']),
    propertyType: enumByName(PropertyType.values, json['propertyType'], PropertyType.MESS),
    rent: asInt(json['rent']),
    roomHeight: asInt(json['roomHeight']),
    roomId: asInt(json['roomId']),
    roomNumber: asString(json['roomNumber']),
    roomType: enumByName(RoomType.values, json['roomType'], RoomType.SINGLE),
    roomWidth: asInt(json['roomWidth']),
    title: asString(json['title']),
  );

  Json toJson() => {
    'ownerAvatarUrl': ownerAvatarUrl,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'address': address,
    'area': area,
    'availableSeats': availableSeats,
    'contactNumber': contactNumber,
    'createdAt': createdAt,
    'deposit': deposit,
    'description': description,
    'district': district,
    'division': division,
    'facilities': facilities,
    'gender': gender.name,
    'images': images,
    'institutionNearby': institutionNearby,
    'propertyId': propertyId,
    'propertyType': propertyType.name,
    'rent': rent,
    'roomHeight': roomHeight,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'roomType': roomType.name,
    'roomWidth': roomWidth,
    'title': title,
  };
}

class PropertyTenantResponse {
  const PropertyTenantResponse({
    this.ownerAvatarUrl,
    required this.ownerId,
    required this.ownerName,
    required this.address,
    required this.area,
    required this.contactNumber,
    required this.createdAt,
    required this.description,
    required this.district,
    required this.division,
    required this.facilities,
    required this.gender,
    required this.institutionNearby,
    required this.propertyId,
    required this.propertyType,
    required this.rooms,
    required this.title,
    required this.totalAvailableSeats,
    required this.totalRooms,
  });

  final String? ownerAvatarUrl;
  final int ownerId;
  final String ownerName;
  final String address;
  final String area;
  final String contactNumber;
  final String createdAt;
  final String description;
  final String district;
  final String division;
  final List<String> facilities;
  final String gender;
  final String institutionNearby;
  final int propertyId;
  final String propertyType;
  final List<RoomTenantResponse> rooms;
  final String title;
  final int totalAvailableSeats;
  final int totalRooms;

  factory PropertyTenantResponse.fromJson(Json json) => PropertyTenantResponse(
    ownerAvatarUrl: asStringOrNull(json['ownerAvatarUrl']),
    ownerId: asInt(json['ownerId']),
    ownerName: asString(json['ownerName']),
    address: asString(json['address']),
    area: asString(json['area']),
    contactNumber: asString(json['contactNumber']),
    createdAt: asString(json['createdAt']),
    description: asString(json['description']),
    district: asString(json['district']),
    division: asString(json['division']),
    facilities: asStringList(json['facilities']),
    gender: asString(json['gender']),
    institutionNearby: asString(json['institutionNearby']),
    propertyId: asInt(json['propertyId']),
    propertyType: asString(json['propertyType']),
    rooms: asList(json['rooms'], RoomTenantResponse.fromJson),
    title: asString(json['title']),
    totalAvailableSeats: asInt(json['totalAvailableSeats']),
    totalRooms: asInt(json['totalRooms']),
  );
}

class SavedRoomsRequest {
  const SavedRoomsRequest(this.roomIds);

  final List<int> roomIds;

  Json toJson() => {'roomIds': roomIds};
}
