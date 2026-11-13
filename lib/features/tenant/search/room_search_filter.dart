import 'package:flutter/foundation.dart';

import '../../../data/enums/enums.dart';

enum SortOption {
  CREATED_AT('createdAt', 'Newest'),
  RENT('rent', 'Rent'),
  AVAILABLE_SEATS('availableSeats', 'Available seats');

  const SortOption(this.apiValue, this.title);

  final String apiValue;
  final String title;
}

enum SortOrder {
  ASC('asc', 'Low to high'),
  DESC('desc', 'High to low');

  const SortOrder(this.apiValue, this.title);

  final String apiValue;
  final String title;
}

@immutable
class RoomSearchFilter {
  const RoomSearchFilter({
    this.keyword = '',
    this.division = '',
    this.district = '',
    this.area = '',
    this.roomType,
    this.minRent = '',
    this.maxRent = '',
    this.minAvailableSeats = '',
    this.maxAvailableSeats = '',
    this.minRoomWidth = '',
    this.minRoomHeight = '',
    this.propertyType,
    this.gender,
    this.sortBy = SortOption.CREATED_AT,
    this.sortOrder = SortOrder.DESC,
  });

  final String keyword;

  final String division;
  final String district;
  final String area;

  final RoomType? roomType;

  final String minRent;
  final String maxRent;

  final String minAvailableSeats;
  final String maxAvailableSeats;

  final String minRoomWidth;
  final String minRoomHeight;

  final String? propertyType;
  final String? gender;

  final SortOption sortBy;
  final SortOrder sortOrder;

  int activeFilterCount() {
    var count = 0;

    if (division.trim().isNotEmpty) count++;
    if (district.trim().isNotEmpty) count++;
    if (area.trim().isNotEmpty) count++;
    if (roomType != null) count++;
    if (minRent.trim().isNotEmpty) count++;
    if (maxRent.trim().isNotEmpty) count++;
    if (minAvailableSeats.trim().isNotEmpty) count++;
    if (maxAvailableSeats.trim().isNotEmpty) count++;
    if (minRoomWidth.trim().isNotEmpty) count++;
    if (minRoomHeight.trim().isNotEmpty) count++;
    if (propertyType != null) count++;
    if (gender != null) count++;

    if (sortBy != SortOption.CREATED_AT || sortOrder != SortOrder.DESC) count++;

    return count;
  }

  static const _unset = Object();

  /// Nullable fields ([roomType], [propertyType], [gender]) can be cleared by passing `null`.
  RoomSearchFilter copyWith({
    String? keyword,
    String? division,
    String? district,
    String? area,
    Object? roomType = _unset,
    String? minRent,
    String? maxRent,
    String? minAvailableSeats,
    String? maxAvailableSeats,
    String? minRoomWidth,
    String? minRoomHeight,
    Object? propertyType = _unset,
    Object? gender = _unset,
    SortOption? sortBy,
    SortOrder? sortOrder,
  }) {
    return RoomSearchFilter(
      keyword: keyword ?? this.keyword,
      division: division ?? this.division,
      district: district ?? this.district,
      area: area ?? this.area,
      roomType: identical(roomType, _unset) ? this.roomType : roomType as RoomType?,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      minAvailableSeats: minAvailableSeats ?? this.minAvailableSeats,
      maxAvailableSeats: maxAvailableSeats ?? this.maxAvailableSeats,
      minRoomWidth: minRoomWidth ?? this.minRoomWidth,
      minRoomHeight: minRoomHeight ?? this.minRoomHeight,
      propertyType: identical(propertyType, _unset) ? this.propertyType : propertyType as String?,
      gender: identical(gender, _unset) ? this.gender : gender as String?,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
