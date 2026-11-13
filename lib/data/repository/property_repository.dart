import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../api/property_api.dart';
import '../common/page_response.dart';
import '../dto/property/property_dtos.dart';
import '../dto/room/room_dtos.dart';

class PropertyRepository {
  PropertyRepository(this._api);

  final PropertyApi _api;

  Future<ApiResult<PropertyResponse>> create(PropertyRequest req) =>
      safeApiCall(() => _api.create(req));

  Future<ApiResult<PropertyResponse>> update(int propertyId, PropertyUpdateRequest req) =>
      safeApiCall(() => _api.update(propertyId, req));

  Future<ApiResult<PageResponse<PropertyResponse>>> findPage(Map<String, String> params) =>
      safeApiCall(() => _api.findPage(params));

  Future<ApiResult<List<PropertyResponse>>> findAll() => safeApiCall(_api.findAll);

  Future<ApiResult<PropertyResponse>> findOne(int id) => safeApiCall(() => _api.findOne(id));

  Future<ApiResult<void>> deleteProperty(int id) => safeApiCall(() => _api.delete(id));

  //========================================
  //    Dashboard
  //========================================

  Future<ApiResult<OwnerDashboardSummaryResponse>> getDashboardSummary() =>
      safeApiCall(_api.getDashboardSummary);

  //========================================
  //    Room
  //========================================

  Future<ApiResult<RoomResponse>> createRoom(int propertyId, RoomRequest body) =>
      safeApiCall(() => _api.createRoom(propertyId, body));

  Future<ApiResult<RoomResponse>> updateRoom(int roomId, RoomRequest body) =>
      safeApiCall(() => _api.updateRoom(roomId, body));

  Future<ApiResult<void>> roomAvailability(RoomAvailabilityRequest body) =>
      safeApiCall(() => _api.roomAvailability(body));
}
