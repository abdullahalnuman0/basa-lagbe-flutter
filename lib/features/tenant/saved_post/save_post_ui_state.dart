import 'package:flutter/foundation.dart';

import '../../../data/dto/tenant/tenant_dtos.dart';

@immutable
class SavePostUiState {
  const SavePostUiState({this.rooms = const [], this.error, this.isLoading = true});

  final List<RoomTenantResponse> rooms;

  final String? error;

  final bool isLoading;
}
