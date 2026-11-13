import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/app_properties.dart';
import '../../../../data/enums/enums.dart';
import '../../../../data/repository/file_repository.dart';
import '../../../../domain/model/room.dart';
import 'room_editor_ui_state.dart';

class RoomEditorViewModel extends ChangeNotifier {
  RoomEditorViewModel(this._fileRepo);

  static const _folder = 'properties';

  final FileRepository _fileRepo;

  RoomEditorUiState _state = const RoomEditorUiState();
  RoomEditorUiState get state => _state;

  bool _disposed = false;

  void _update(RoomEditorUiState Function(RoomEditorUiState s) transform) {
    _state = transform(_state);
    if (!_disposed) notifyListeners();
  }

  // ====================================
  //      Room form initialization
  // ====================================
  void initialRoom(Room? room) {
    if (room == null) return;
    String orEmpty(int v) => v != 0 ? '$v' : '';

    _update(
      (_) => RoomEditorUiState(
        roomNumber: room.roomNumber,
        rent: orEmpty(room.rent),
        deposit: orEmpty(room.deposit),
        availableSeats: orEmpty(room.availableSeats),
        roomWidth: orEmpty(room.roomWidth),
        roomHeight: orEmpty(room.roomHeight),
        type: room.type,
        images: [for (final key in room.images) ImageStash(fileKey: key)],
      ),
    );
  }

  void closeInitial(bool deleteImage) {
    final fileKeys = _state.images.map((it) => it.fileKey).nonNulls.toList();
    _update((_) => const RoomEditorUiState());

    if (deleteImage) _fileRepo.deleteAll(fileKeys);
  }

  void onRoomNumberChange(String v) =>
      _update((s) => s.copyWith(roomNumber: v, roomNumberError: _required(v, 'Room number')));

  void onTypeSelected(RoomType t) => _update((s) => s.copyWith(type: t, typeError: null));

  void onSeatChange(String value) => _update(
    (s) => s.copyWith(
      availableSeats: value,
      availableSeatsError: _positiveInt(value, 'Available seats'),
    ),
  );

  void onRentChange(String value) =>
      _update((s) => s.copyWith(rent: value, rentError: _positiveInt(value, 'Rent')));

  void onDepositChange(String value) => _update((s) => s.copyWith(deposit: value));

  void onWidthChange(String value) => _update(
    (s) => s.copyWith(roomWidth: value, roomWidthError: _positiveInt(value, 'Room width')),
  );

  void onHeightChange(String value) => _update(
    (s) => s.copyWith(roomHeight: value, roomHeightError: _positiveInt(value, 'Room height')),
  );

  // ====================================
  //      Image upload
  // ====================================
  Future<void> onUploadImages(List<XFile> files) async {
    if (_state.isLoading) return;

    final remainingSlots = AppProperties.propertyMaxFile - _state.images.length;
    if (remainingSlots <= 0) return;

    final toUpload = files.take(remainingSlots).toList();

    _update(
      (s) => s.copyWith(
        images: [
          ...s.images,
          for (final file in toUpload) ImageStash(file: file, isUploading: true),
        ],
        isLoading: true,
        imageError: null,
      ),
    );

    for (final file in toUpload) {
      await _upload(file);
    }

    _update((s) => s.copyWith(isLoading: false));
  }

  void onRemoveImage(ImageStash value) {
    _update((s) => s.copyWith(images: [...s.images]..remove(value)));
    final key = value.fileKey;
    if (key != null) _fileRepo.delete(key).ignore();
  }

  Future<void> onRetry(int index, ImageStash stash) async {
    final file = stash.file;
    if (file == null || _state.images[index].isUploading) return;

    _replace(file, (it) => it.copyWith(error: null, isUploading: true));
    await _upload(file);
  }

  Future<void> _upload(XFile file) async {
    final result = await _fileRepo.upload(file, _folder);
    switch (result) {
      case ApiError(:final message):
        _replace(file, (it) => it.copyWith(error: message, isUploading: false));
      case ApiSuccess(:final data):
        _replace(file, (it) => it.copyWith(fileKey: data, isUploading: false));
    }
  }

  // Looked up by file rather than position, so removing a photo mid-upload can't shift results.
  void _replace(XFile file, ImageStash Function(ImageStash it) transform) {
    final index = _state.images.indexWhere((it) => identical(it.file, file));
    if (index == -1) return;
    _update((s) => s.copyWith(images: [...s.images]..[index] = transform(s.images[index])));
  }

  // ====================================
  //      Add room
  // ====================================
  void onAddRoom(ValueChanged<Room> onSave) {
    _validateForm();
    if (_state.isValid) onSave(_state.toRoom());
  }

  void _validateForm() => _update(
    (s) => s.copyWith(
      roomNumberError: _required(s.roomNumber, 'Room number'),
      rentError: _positiveInt(s.rent, 'Rent'),
      availableSeatsError: _positiveInt(s.availableSeats, 'Available seats'),
      roomWidthError: _positiveInt(s.roomWidth, 'Room width'),
      roomHeightError: _positiveInt(s.roomHeight, 'Room height'),
      typeError: s.type == null ? 'Please select room type' : null,
      imageError: s.images.every((it) => it.fileKey == null)
          ? 'Please select at last one image.'
          : null,
    ),
  );

  static String? _required(String value, String fieldName) =>
      value.trim().isEmpty ? '$fieldName is required.' : null;

  static String? _positiveInt(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName is required';
    final num = int.tryParse(value);
    if (num == null) return 'Give the correct number.';
    if (num <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
