import 'package:dio/dio.dart';

import '../common/json.dart';
import '../common/page_response.dart';
import '../dto/property/property_dtos.dart';
import '../dto/room/room_dtos.dart';

class PropertyApi {
  PropertyApi(this._dio);

  final Dio _dio;

  Future<PropertyResponse> create(PropertyRequest body) async {
    final res = await _dio.post<Json>('owner/properties', data: body.toJson());
    return PropertyResponse.fromJson(res.data!);
  }

  Future<PropertyResponse> update(int propertyId, PropertyUpdateRequest body) async {
    final res = await _dio.put<Json>('owner/properties/$propertyId', data: body.toJson());
    return PropertyResponse.fromJson(res.data!);
  }

  Future<PageResponse<PropertyResponse>> findPage(Map<String, String> params) async {
    final res = await _dio.get<Json>('owner/properties', queryParameters: params);
    return PageResponse.fromJson(res.data!, PropertyResponse.fromJson);
  }

  Future<List<PropertyResponse>> findAll() async {
    final res = await _dio.get<List<dynamic>>('owner/properties/all');
    return asList(res.data, PropertyResponse.fromJson);
  }

  Future<PropertyResponse> findOne(int id) async {
    final res = await _dio.get<Json>('owner/properties/$id');
    return PropertyResponse.fromJson(res.data!);
  }

  Future<void> delete(int id) async {
    await _dio.delete<dynamic>('owner/properties/$id');
  }

  //==========================================
  //    Owner Dashboard
  //==========================================

  Future<OwnerDashboardSummaryResponse> getDashboardSummary() async {
    final res = await _dio.get<Json>('owner/properties/dashboard/summary');
    return OwnerDashboardSummaryResponse.fromJson(res.data!);
  }

  //========================================
  //    Room
  //========================================

  Future<RoomResponse> createRoom(int propertyId, RoomRequest body) async {
    final res = await _dio.post<Json>('owner/properties/room/$propertyId', data: body.toJson());
    return RoomResponse.fromJson(res.data!);
  }

  Future<RoomResponse> updateRoom(int roomId, RoomRequest body) async {
    final res = await _dio.put<Json>('owner/properties/room/$roomId', data: body.toJson());
    return RoomResponse.fromJson(res.data!);
  }

  Future<void> roomAvailability(RoomAvailabilityRequest body) async {
    await _dio.put<dynamic>('owner/properties/room/availability', data: body.toJson());
  }
}
