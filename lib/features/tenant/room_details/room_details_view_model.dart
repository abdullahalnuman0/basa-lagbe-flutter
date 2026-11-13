import 'package:flutter/foundation.dart';

import '../../../core/data/favorites_manager.dart';
import '../../../core/network/api_result.dart';
import '../../../data/repository/chat_repository.dart';
import '../../../data/repository/tenant_repository.dart';
import 'room_details_ui_state.dart';

class RoomDetailsViewModel extends ChangeNotifier {
  RoomDetailsViewModel(this.roomId, this._tenantRepo, this._chatRepo, this._favorite) {
    loadRoom();
  }

  final int roomId;
  final TenantRepository _tenantRepo;
  final ChatRepository _chatRepo;
  final FavoritesManager _favorite;

  RoomDetailsUiState _uiState = const RoomDetailsUiState();
  bool _disposed = false;

  RoomDetailsUiState get uiState => _uiState;

  Future<void> loadRoom() async {
    final r = await _tenantRepo.findRoom(roomId);
    _uiState = switch (r) {
      ApiSuccess(:final data) => RoomDetailsUiState(
        roomId: roomId,
        room: data,
        isFavorite: _favorite.isFavorite(roomId),
        isLoading: false,
      ),
      ApiError(:final message) => RoomDetailsUiState(
        roomId: roomId,
        error: message,
        isLoading: false,
      ),
    };
    _notify();
  }

  Future<void> updateFavoriteState(void Function(bool saved) done) async {
    final state = _uiState;
    if (state.isFavorite) {
      await _favorite.removeFavorite(state.roomId);
    } else {
      await _favorite.addFavorite(state.roomId);
    }
    done(!state.isFavorite);
    _update(_uiState.copyWith(isFavorite: !state.isFavorite));
  }

  Future<void> openChat({
    required void Function(int chatId) onChat,
    required void Function(String message) onError,
  }) async {
    _update(_uiState.copyWith(isChatOpening: true));
    switch (await _chatRepo.open(_uiState.roomId)) {
      case ApiSuccess(:final data):
        onChat(data.id);
      case ApiError(:final message):
        onError(message);
    }
    _update(_uiState.copyWith(isChatOpening: false));
  }

  void _update(RoomDetailsUiState state) {
    _uiState = state;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
