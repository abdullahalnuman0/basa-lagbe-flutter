import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../data/dto/room/room_dtos.dart';
import '../../../data/repository/property_repository.dart';
import '../../../domain/model/room.dart';
import 'property_details_ui_state.dart';

class PropertyDetailsViewModel extends ChangeNotifier {
  PropertyDetailsViewModel(this._propertyRepo);

  final PropertyRepository _propertyRepo;

  PropertyDetailsUiState _state = const PropertyDetailsUiState();
  bool _disposed = false;

  PropertyDetailsUiState get state => _state;

  void _update(PropertyDetailsUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  Future<void> loadProperty([int? propertyId]) async {
    final id = propertyId ?? _state.propertyId;

    if (id == null) {
      _update(_state.copyWith(isLoading: false, error: "Don't have any ID."));
      return;
    }

    _update(_state.copyWith(propertyId: id, isLoading: true, error: null));

    switch (await _propertyRepo.findOne(id)) {
      case ApiError(:final message):
        _update(_state.copyWith(isLoading: false, error: message));
      case ApiSuccess(:final data):
        _update(_state.copyWith(isLoading: false, error: null, property: data));
    }
  }

  void toggleDeleteDialog([bool? value]) {
    _update(_state.copyWith(showDeleteAlert: value ?? !_state.showDeleteAlert));
  }

  Future<void> deleteProperty({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    _update(_state.copyWith(isLoading: true, showDeleteAlert: false));

    switch (await _propertyRepo.deleteProperty(_state.propertyId!)) {
      case ApiError(:final message):
        _update(_state.copyWith(isLoading: false, error: message));
        onError(message);
      case ApiSuccess():
        _update(_state.copyWith(isLoading: false));
        onSuccess();
    }
  }

  void onSearchValueChange(String value) => _update(_state.copyWith(searchText: value));

  void onSearchValueClear() => _update(_state.copyWith(searchText: ''));

  Future<void> onUpdateRoom(
    int index,
    RoomResponse room, {
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    _update(_state.copyWith(isForceLoading: true));

    final body = RoomRequest(
      availableSeats: room.availableSeats,
      deposit: room.deposit,
      images: room.images,
      rent: room.rent,
      roomHeight: room.roomHeight,
      roomNumber: room.roomNumber,
      roomWidth: room.roomWidth,
      type: room.type,
    );

    switch (await _propertyRepo.updateRoom(_state.property!.rooms[index].id, body)) {
      case ApiError(:final message):
        _update(_state.copyWith(isForceLoading: false));
        onError(message);
      case ApiSuccess(:final data):
        _update(_state.copyWith(property: _replaceRoom(index, (_) => data), isForceLoading: false));
        onSuccess();
    }
  }

  Future<void> onAddRoom(
    Room room, {
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    _update(_state.copyWith(isForceLoading: true));

    final body = RoomRequest(
      availableSeats: room.availableSeats,
      deposit: room.deposit,
      images: room.images,
      rent: room.rent,
      roomHeight: room.roomHeight,
      roomNumber: room.roomNumber,
      roomWidth: room.roomWidth,
      type: room.type!,
    );

    switch (await _propertyRepo.createRoom(_state.propertyId!, body)) {
      case ApiError(:final message):
        _update(_state.copyWith(isForceLoading: false));
        onError(message);
      case ApiSuccess(:final data):
        final property = _state.property;
        _update(
          _state.copyWith(
            property: property?.copyWith(rooms: [...property.rooms, data]),
            isForceLoading: false,
          ),
        );
        onSuccess();
    }
  }

  Future<void> onAvailability(
    int index,
    int newAvailability, {
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    _update(_state.copyWith(isForceLoading: true));

    final availability = newAvailability <= -1 ? 0 : newAvailability;
    final request = RoomAvailabilityRequest(
      roomId: _state.property!.rooms[index].id,
      availableSeats: availability,
    );

    switch (await _propertyRepo.roomAvailability(request)) {
      case ApiError(:final message):
        _update(_state.copyWith(isForceLoading: false));
        onError(message);
      case ApiSuccess():
        _update(
          _state.copyWith(
            property: _replaceRoom(index, (r) => r.copyWith(availableSeats: availability)),
            isForceLoading: false,
          ),
        );
        onSuccess();
    }
  }

  PropertyResponse? _replaceRoom(int index, RoomResponse Function(RoomResponse) transform) {
    final property = _state.property;
    if (property == null) return null;
    final rooms = [...property.rooms];
    rooms[index] = transform(rooms[index]);
    return property.copyWith(rooms: rooms);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
