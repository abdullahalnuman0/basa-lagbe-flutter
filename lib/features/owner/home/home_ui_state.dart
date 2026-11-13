import '../../../data/dto/property/property_dtos.dart';

const _unset = Object();

class HomeUiState {
  const HomeUiState({
    this.properties,
    this.dashboardSummary,
    this.sortPosition = 0,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.refreshError,
  });

  final List<PropertyResponse>? properties;
  final OwnerDashboardSummaryResponse? dashboardSummary;

  final int sortPosition;

  final bool isLoading; // initial loading
  final bool isRefreshing; // pull-to-refresh
  final String? error; // initial load error
  final String? refreshError;

  HomeUiState copyWith({
    List<PropertyResponse>? properties,
    OwnerDashboardSummaryResponse? dashboardSummary,
    int? sortPosition,
    bool? isLoading,
    bool? isRefreshing,
    Object? error = _unset,
    Object? refreshError = _unset,
  }) {
    return HomeUiState(
      properties: properties ?? this.properties,
      dashboardSummary: dashboardSummary ?? this.dashboardSummary,
      sortPosition: sortPosition ?? this.sortPosition,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: identical(error, _unset) ? this.error : error as String?,
      refreshError: identical(refreshError, _unset) ? this.refreshError : refreshError as String?,
    );
  }
}
