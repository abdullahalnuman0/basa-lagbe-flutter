import 'package:flutter/foundation.dart';

import '../../../core/data/session_manager.dart';
import '../../../core/network/api_result.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../data/common/page_response.dart';
import '../../../data/dto/tenant/tenant_dtos.dart';
import '../../../data/repository/tenant_repository.dart';
import '../../auth/signup/location_data.dart';
import 'room_search_filter.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._repo, this._session) {
    if (_session.user != null) {
      _start();
    } else {
      _session.addListener(_waitForUser);
    }
  }

  final TenantRepository _repo;
  final SessionManager _session;

  late final roomLoader = PageLoader<RoomTenantResponse>(_loadRooms);

  RoomSearchFilter _filter = const RoomSearchFilter();
  bool _filterSheetVisible = false;
  bool _disposed = false;

  RoomSearchFilter get filter => _filter;

  bool get filterSheetVisible => _filterSheetVisible;

  void _waitForUser() {
    if (_session.user == null) return;
    _session.removeListener(_waitForUser);
    _start();
  }

  void _start() {
    final user = _session.user!;
    final division = user.division ?? LocationData.divisions[0];
    _filter = _filter.copyWith(
      division: division,
      district: user.district ?? LocationData.districtByDivision[division]![0],
    );
    _notify();
    roomLoader.loadFirst();
  }

  Future<ApiResult<PageResponse<RoomTenantResponse>>> _loadRooms(int page) {
    final current = _filter;

    final params = <String, String>{'page': '$page', 'size': '10'};

    final keyword = current.keyword.trim();
    if (keyword.isNotEmpty) params['keyword'] = keyword;

    if (current.division.trim().isNotEmpty) params['division'] = current.division;
    if (current.district.trim().isNotEmpty) params['district'] = current.district;
    if (current.area.trim().isNotEmpty) params['area'] = current.area;

    if (current.roomType case final roomType?) params['roomType'] = roomType.name;

    void putInt(String key, String value) {
      final number = int.tryParse(value);
      if (number != null) params[key] = '$number';
    }

    putInt('minRent', current.minRent);
    putInt('maxRent', current.maxRent);
    putInt('minAvailableSeats', current.minAvailableSeats);
    putInt('maxAvailableSeats', current.maxAvailableSeats);

    final width = int.tryParse(current.minRoomWidth);
    final height = int.tryParse(current.minRoomHeight);
    if (width != null && height != null) params['minRoomSize'] = '${width * height}';

    if (current.propertyType case final type?) params['propertyType'] = type;
    if (current.gender case final gender?) params['gender'] = gender;

    params['sort'] = '${current.sortBy.apiValue},${current.sortOrder.apiValue}';

    return _repo.findRooms(params);
  }

  //==============================
  // Keyword search
  //==============================
  void updateKeyword(String value) {
    _filter = _filter.copyWith(keyword: value);
    _notify();
  }

  void submitSearch() => roomLoader.loadFirst();

  void updateFilter(RoomSearchFilter Function(RoomSearchFilter old) transform) {
    _filter = transform(_filter);
    _notify();
  }

  void applyFilters() {
    _filterSheetVisible = false;
    _notify();
    roomLoader.loadFirst();
  }

  void clearFilters() {
    _filter = const RoomSearchFilter();
    _filterSheetVisible = false;
    _notify();
    roomLoader.loadFirst();
  }

  void openFilterSheet() {
    _filterSheetVisible = true;
    _notify();
  }

  void closeFilterSheet() {
    if (!_filterSheetVisible) return;
    _filterSheetVisible = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _session.removeListener(_waitForUser);
    roomLoader.dispose();
    super.dispose();
  }
}
