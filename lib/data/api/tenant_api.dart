import 'package:dio/dio.dart';

import '../common/json.dart';
import '../common/page_response.dart';
import '../dto/tenant/tenant_dtos.dart';

class TenantApi {
  TenantApi(this._dio);

  final Dio _dio;

  Map<String, String> _clean(Map<String, String?> params) => {
    for (final e in params.entries)
      if (e.value != null) e.key: e.value!,
  };

  Future<PageResponse<RoomTenantResponse>> findRooms(Map<String, String?> params) async {
    final res = await _dio.get<Json>('tenant/rooms', queryParameters: _clean(params));
    return PageResponse.fromJson(res.data!, RoomTenantResponse.fromJson);
  }

  Future<RoomTenantResponse> findRoom(int id) async {
    final res = await _dio.get<Json>('tenant/rooms/$id');
    return RoomTenantResponse.fromJson(res.data!);
  }

  Future<PageResponse<PropertyTenantResponse>> findProperties(Map<String, String?> params) async {
    final res = await _dio.get<Json>('tenant/properties', queryParameters: _clean(params));
    return PageResponse.fromJson(res.data!, PropertyTenantResponse.fromJson);
  }

  Future<PropertyTenantResponse> findProperty(int id) async {
    final res = await _dio.get<Json>('tenant/properties/$id');
    return PropertyTenantResponse.fromJson(res.data!);
  }

  Future<void> updateRoomView(int id) async {
    await _dio.put<dynamic>('tenant/rooms/$id');
  }

  Future<List<RoomTenantResponse>> getSavedRooms(SavedRoomsRequest body) async {
    final res = await _dio.post<List<dynamic>>('tenant/rooms/saved', data: body.toJson());
    return asList(res.data, RoomTenantResponse.fromJson);
  }
}
