import '../../../domain/enums/property_gender.dart';
import '../../../domain/enums/property_type.dart';
import '../../common/json.dart';
import '../../enums/enums.dart';
import '../room/room_dtos.dart';

class OwnerDashboardSummaryResponse {
  const OwnerDashboardSummaryResponse({
    required this.activeListings,
    required this.pendingApproval,
    required this.availableSeats,
    required this.totalRoom,
    required this.approvedRoom,
    required this.pendingRoom,
  });

  final int activeListings;
  final int pendingApproval;
  final int availableSeats;
  final int totalRoom;
  final int approvedRoom;
  final int pendingRoom;

  factory OwnerDashboardSummaryResponse.fromJson(Json json) => OwnerDashboardSummaryResponse(
    activeListings: asInt(json['activeListings']),
    pendingApproval: asInt(json['pendingApproval']),
    availableSeats: asInt(json['availableSeats']),
    totalRoom: asInt(json['totalRoom']),
    approvedRoom: asInt(json['approvedRoom']),
    pendingRoom: asInt(json['pendingRoom']),
  );
}

class PropertyRequest {
  const PropertyRequest({
    required this.address,
    required this.area,
    required this.contactNumber,
    required this.description,
    required this.district,
    required this.division,
    required this.facilities,
    required this.gender,
    this.institutionNearby,
    required this.rooms,
    required this.title,
    required this.type,
  });

  final String address;
  final String area;
  final String contactNumber;
  final String description;
  final String district;
  final String division;
  final List<String> facilities;
  final PropertyGender gender;
  final String? institutionNearby;
  final List<RoomRequest> rooms;
  final String title;
  final PropertyType type;

  Json toJson() => {
    'address': address,
    'area': area,
    'contactNumber': contactNumber,
    'description': description,
    'district': district,
    'division': division,
    'facilities': facilities,
    'gender': gender.name,
    'institutionNearby': institutionNearby,
    'rooms': rooms.map((r) => r.toJson()).toList(),
    'title': title,
    'type': type.name,
  };
}

class PropertyUpdateRequest {
  const PropertyUpdateRequest({
    required this.address,
    required this.area,
    required this.contactNumber,
    required this.description,
    required this.district,
    required this.division,
    required this.facilities,
    required this.gender,
    this.institutionNearby,
    required this.title,
    required this.type,
  });

  final String address;
  final String area;
  final String contactNumber;
  final String description;
  final String district;
  final String division;
  final List<String> facilities;
  final PropertyGender gender;
  final String? institutionNearby;
  final String title;
  final PropertyType type;

  Json toJson() => {
    'address': address,
    'area': area,
    'contactNumber': contactNumber,
    'description': description,
    'district': district,
    'division': division,
    'facilities': facilities,
    'gender': gender.name,
    'institutionNearby': institutionNearby,
    'title': title,
    'type': type.name,
  };
}

class PropertyResponse {
  const PropertyResponse({
    this.totalViews = 0,
    required this.id,
    required this.title,
    required this.description,
    required this.approved,
    required this.division,
    required this.district,
    required this.area,
    required this.address,
    required this.contactNumber,
    required this.gender,
    required this.type,
    required this.institutionNearby,
    required this.facilities,
    required this.rooms,
    required this.createdAt,
  });

  final int totalViews;
  final int id;
  final String title;
  final String description;
  final bool approved;
  final String division;
  final String district;
  final String area;
  final String address;
  final String contactNumber;
  final PropertyGender gender;
  final PropertyType type;
  final String institutionNearby;
  final List<String> facilities;
  final List<RoomResponse> rooms;
  final DateTime createdAt;

  factory PropertyResponse.fromJson(Json json) => PropertyResponse(
    totalViews: asInt(json['totalViews']),
    id: asInt(json['id']),
    title: asString(json['title']),
    description: asString(json['description']),
    approved: asBool(json['approved']),
    division: asString(json['division']),
    district: asString(json['district']),
    area: asString(json['area']),
    address: asString(json['address']),
    contactNumber: asString(json['contactNumber']),
    gender: enumByName(PropertyGender.values, json['gender'], PropertyGender.ANY),
    type: enumByName(PropertyType.values, json['type'], PropertyType.MESS),
    institutionNearby: asString(json['institutionNearby']),
    facilities: asStringList(json['facilities']),
    rooms: asList(json['rooms'], RoomResponse.fromJson),
    createdAt: parseInstant(json['createdAt']),
  );

  Json toJson() => {
    'totalViews': totalViews,
    'id': id,
    'title': title,
    'description': description,
    'approved': approved,
    'division': division,
    'district': district,
    'area': area,
    'address': address,
    'contactNumber': contactNumber,
    'gender': gender.name,
    'type': type.name,
    'institutionNearby': institutionNearby,
    'facilities': facilities,
    'rooms': rooms.map((r) => r.toJson()).toList(),
    'createdAt': instantToString(createdAt),
  };

  PropertyResponse copyWith({List<RoomResponse>? rooms, bool? approved}) => PropertyResponse(
    totalViews: totalViews,
    id: id,
    title: title,
    description: description,
    approved: approved ?? this.approved,
    division: division,
    district: district,
    area: area,
    address: address,
    contactNumber: contactNumber,
    gender: gender,
    type: type,
    institutionNearby: institutionNearby,
    facilities: facilities,
    rooms: rooms ?? this.rooms,
    createdAt: createdAt,
  );
}
