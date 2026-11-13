import 'package:image_picker/image_picker.dart';

import '../../../../data/enums/enums.dart';
import '../../../../domain/model/room.dart';

const _keep = Object();

class RoomEditorUiState {
  const RoomEditorUiState({
    this.roomNumber = '',
    this.rent = '',
    this.deposit = '',
    this.availableSeats = '',
    this.roomWidth = '',
    this.roomHeight = '',
    this.type,
    this.images = const [],
    this.roomNumberError,
    this.rentError,
    this.availableSeatsError,
    this.roomWidthError,
    this.roomHeightError,
    this.typeError,
    this.imageError,
    this.isLoading = false,
  });

  final String roomNumber;
  final String rent;
  final String deposit;
  final String availableSeats;
  final String roomWidth;
  final String roomHeight;
  final RoomType? type;
  final List<ImageStash> images;

  final String? roomNumberError;
  final String? rentError;
  final String? availableSeatsError;
  final String? roomWidthError;
  final String? roomHeightError;
  final String? typeError;
  final String? imageError;

  final bool isLoading;

  bool get isValid =>
      roomNumberError == null &&
      rentError == null &&
      availableSeatsError == null &&
      roomWidthError == null &&
      roomHeightError == null &&
      typeError == null &&
      roomNumber.trim().isNotEmpty &&
      rent.trim().isNotEmpty &&
      availableSeats.trim().isNotEmpty &&
      roomWidth.trim().isNotEmpty &&
      roomHeight.trim().isNotEmpty &&
      type != null &&
      images.isNotEmpty;

  bool get isBusy => isLoading || images.any((it) => it.isUploading);

  Room toRoom() => Room(
    availableSeats: int.tryParse(availableSeats) ?? 0,
    deposit: int.tryParse(deposit) ?? 0,
    images: images.map((it) => it.fileKey ?? '').toList(),
    rent: int.tryParse(rent) ?? 0,
    roomHeight: int.tryParse(roomHeight) ?? 0,
    roomNumber: roomNumber.trim(),
    roomWidth: int.tryParse(roomWidth) ?? 0,
    type: type,
  );

  RoomEditorUiState copyWith({
    String? roomNumber,
    String? rent,
    String? deposit,
    String? availableSeats,
    String? roomWidth,
    String? roomHeight,
    RoomType? type,
    List<ImageStash>? images,
    Object? roomNumberError = _keep,
    Object? rentError = _keep,
    Object? availableSeatsError = _keep,
    Object? roomWidthError = _keep,
    Object? roomHeightError = _keep,
    Object? typeError = _keep,
    Object? imageError = _keep,
    bool? isLoading,
  }) {
    String? pick(Object? value, String? current) =>
        identical(value, _keep) ? current : value as String?;

    return RoomEditorUiState(
      roomNumber: roomNumber ?? this.roomNumber,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      availableSeats: availableSeats ?? this.availableSeats,
      roomWidth: roomWidth ?? this.roomWidth,
      roomHeight: roomHeight ?? this.roomHeight,
      type: type ?? this.type,
      images: images ?? this.images,
      roomNumberError: pick(roomNumberError, this.roomNumberError),
      rentError: pick(rentError, this.rentError),
      availableSeatsError: pick(availableSeatsError, this.availableSeatsError),
      roomWidthError: pick(roomWidthError, this.roomWidthError),
      roomHeightError: pick(roomHeightError, this.roomHeightError),
      typeError: pick(typeError, this.typeError),
      imageError: pick(imageError, this.imageError),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// A picked photo and its upload progress. Photos that already live on the server have no [file].
class ImageStash {
  const ImageStash({this.file, this.fileKey, this.error, this.isUploading = false});

  final XFile? file;
  final String? fileKey;
  final String? error;
  final bool isUploading;

  ImageStash copyWith({String? fileKey, Object? error = _keep, bool? isUploading}) => ImageStash(
    file: file,
    fileKey: fileKey ?? this.fileKey,
    error: identical(error, _keep) ? this.error : error as String?,
    isUploading: isUploading ?? this.isUploading,
  );
}
