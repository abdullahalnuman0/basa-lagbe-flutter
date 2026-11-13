import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../data/repository/property_repository.dart';
import 'home_ui_state.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._propertyRepo) {
    loadData();
  }

  final PropertyRepository _propertyRepo;

  HomeUiState _state = const HomeUiState();
  bool _disposed = false;

  HomeUiState get state => _state;

  void _update(HomeUiState state) {
    _state = state;
    if (!_disposed) notifyListeners();
  }

  Future<void> loadData({VoidCallback? onError}) async {
    if (_state.isLoading || _state.isRefreshing) return;

    final hasSummary = _state.dashboardSummary != null;
    _update(_state.copyWith(isLoading: !hasSummary, isRefreshing: hasSummary));

    final r = await _propertyRepo.findAll();
    if (_disposed) return;

    switch (r) {
      case ApiError(:final message):
        _update(_state.copyWith(error: message, isLoading: false, isRefreshing: false));
        onError?.call();
      case ApiSuccess(:final data):
        _update(
          _state.copyWith(
            dashboardSummary: _summaryOf(data),
            properties: data,
            isLoading: false,
            isRefreshing: false,
          ),
        );
    }
  }

  void sortPositionChange(int position) => _update(_state.copyWith(sortPosition: position));

  OwnerDashboardSummaryResponse _summaryOf(List<PropertyResponse> properties) {
    final approved = properties.where((p) => p.approved);
    final pending = properties.where((p) => !p.approved);
    final rooms = properties.expand((p) => p.rooms);
    return OwnerDashboardSummaryResponse(
      activeListings: approved.length,
      pendingApproval: pending.length,
      availableSeats: rooms.fold(0, (sum, room) => sum + room.availableSeats),
      totalRoom: rooms.length,
      approvedRoom: approved.expand((p) => p.rooms).length,
      pendingRoom: pending.expand((p) => p.rooms).length,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
