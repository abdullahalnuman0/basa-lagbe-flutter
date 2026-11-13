import 'package:flutter/foundation.dart';

import '../../../core/data/session_manager.dart';
import '../../../core/network/api_result.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../core/utils/app_properties.dart';
import '../../../data/common/page_response.dart';
import '../../../data/dto/tenant/tenant_dtos.dart';
import '../../../data/repository/tenant_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repo, this._session) {
    if (_session.user != null) {
      loader.loadFirst();
    } else {
      _session.addListener(_waitForUser);
    }
  }

  final TenantRepository _repo;
  final SessionManager _session;

  late final loader = PageLoader<RoomTenantResponse>(_loadNearbyRooms);

  // first page is loaded as soon as the user is available
  void _waitForUser() {
    if (_session.user == null) return;
    _session.removeListener(_waitForUser);
    loader.loadFirst();
  }

  Future<ApiResult<PageResponse<RoomTenantResponse>>> _loadNearbyRooms(int page) {
    final user = _session.user;
    if (user == null) throw StateError('User must be loaded before loading nearby rooms');

    return _repo.findRooms({
      'page': '$page',
      'size': '${AppProperties.feedPageSize}',
      'division': user.division,
      'district': user.district,
    });
  }

  @override
  void dispose() {
    _session.removeListener(_waitForUser);
    loader.dispose();
    super.dispose();
  }
}
