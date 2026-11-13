import '../../../data/dto/property/property_dtos.dart';

const _unset = Object();

class PropertyDetailsUiState {
  const PropertyDetailsUiState({
    this.propertyId,
    this.property,
    this.searchText = '',
    this.showDeleteAlert = false,
    this.isLoading = true,
    this.isRefreshing = false,
    this.isForceLoading = false,
    this.error,
  });

  final int? propertyId;
  final PropertyResponse? property;

  final String searchText;

  final bool showDeleteAlert;

  final bool isLoading;
  final bool isRefreshing;
  final bool isForceLoading;

  final String? error;

  PropertyDetailsUiState copyWith({
    int? propertyId,
    PropertyResponse? property,
    String? searchText,
    bool? showDeleteAlert,
    bool? isLoading,
    bool? isRefreshing,
    bool? isForceLoading,
    Object? error = _unset,
  }) {
    return PropertyDetailsUiState(
      propertyId: propertyId ?? this.propertyId,
      property: property ?? this.property,
      searchText: searchText ?? this.searchText,
      showDeleteAlert: showDeleteAlert ?? this.showDeleteAlert,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isForceLoading: isForceLoading ?? this.isForceLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
