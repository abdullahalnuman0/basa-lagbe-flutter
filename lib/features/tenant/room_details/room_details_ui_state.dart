import 'package:flutter/foundation.dart';

import '../../../data/dto/tenant/tenant_dtos.dart';

@immutable
class RoomDetailsUiState {
  const RoomDetailsUiState({
    this.roomId = 0,
    this.room,
    this.isFavorite = false,
    this.isChatOpening = false,
    this.error,
    this.isLoading = true,
  });

  final int roomId;
  final RoomTenantResponse? room;
  final bool isFavorite;
  final bool isChatOpening;

  final String? error;

  final bool isLoading;

  RoomDetailsUiState copyWith({bool? isFavorite, bool? isChatOpening}) => RoomDetailsUiState(
    roomId: roomId,
    room: room,
    isFavorite: isFavorite ?? this.isFavorite,
    isChatOpening: isChatOpening ?? this.isChatOpening,
    error: error,
    isLoading: isLoading,
  );
}
