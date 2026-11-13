import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../api/tenant_api.dart';
import '../common/page_response.dart';
import '../dto/tenant/tenant_dtos.dart';

class TenantRepository {
  TenantRepository(this._api);

  final TenantApi _api;

  Future<ApiResult<PageResponse<RoomTenantResponse>>> findRooms(Map<String, String?> params) =>
      safeApiCall(() => _api.findRooms(params));

  Future<ApiResult<RoomTenantResponse>> findRoom(int id) => safeApiCall(() => _api.findRoom(id));

  Future<ApiResult<PageResponse<PropertyTenantResponse>>> findProperties(
    Map<String, String?> params,
  ) => safeApiCall(() => _api.findProperties(params));

  Future<ApiResult<PropertyTenantResponse>> findProperty(int id) =>
      safeApiCall(() => _api.findProperty(id));

  Future<ApiResult<void>> updateRoomView(int id) => safeApiCall(() => _api.updateRoomView(id));

  Future<ApiResult<List<RoomTenantResponse>>> getSavedRooms(List<int> roomIds) =>
      safeApiCall(() => _api.getSavedRooms(SavedRoomsRequest(roomIds)));
}
