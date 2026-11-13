import 'package:flutter/foundation.dart';

import '../../../core/data/favorites_manager.dart';
import '../../../core/network/api_result.dart';
import '../../../data/repository/tenant_repository.dart';
import 'save_post_ui_state.dart';

class SavePostViewModel extends ChangeNotifier {
  SavePostViewModel(this._repo, this._manager) {
    _roomIds = _manager.favoritePostIds;
    _manager.addListener(_onFavoritesChanged);
    loadSaveRooms();
  }

  final TenantRepository _repo;
  final FavoritesManager _manager;

  late Set<String> _roomIds;
  SavePostUiState _uiState = const SavePostUiState();
  int _generation = 0;
  bool _disposed = false;

  Set<String> get roomIds => _roomIds;

  SavePostUiState get uiState => _uiState;

  void _onFavoritesChanged() {
    final ids = _manager.favoritePostIds;
    if (setEquals(ids, _roomIds)) return;
    _roomIds = ids;
    loadSaveRooms();
  }

  Future<void> loadSaveRooms() async {
    // a newer id set makes any in-flight request stale
    final gen = ++_generation;
    final ids = _roomIds;

    if (ids.isEmpty) {
      _update(const SavePostUiState(isLoading: false));
      return;
    }

    final r = await _repo.getSavedRooms(ids.map(int.parse).toList());
    if (gen != _generation) return;

    _update(switch (r) {
      ApiSuccess(:final data) => SavePostUiState(rooms: data, isLoading: false),
      ApiError(:final message) => SavePostUiState(error: message, isLoading: false),
    });
  }

  void _update(SavePostUiState state) {
    _uiState = state;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _manager.removeListener(_onFavoritesChanged);
    super.dispose();
  }
}
