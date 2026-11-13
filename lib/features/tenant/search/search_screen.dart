import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/room_item_card.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'components/room_filter_bottom_sheet.dart';
import 'components/search_header.dart';
import 'search_view_model.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(locator(), locator()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final SearchViewModel _vm;
  bool _sheetOpen = false;
  BuildContext? _sheetContext;

  @override
  void initState() {
    super.initState();
    _vm = context.read<SearchViewModel>();
    _vm.addListener(_syncFilterSheet);
  }

  @override
  void dispose() {
    _vm.removeListener(_syncFilterSheet);
    super.dispose();
  }

  void _syncFilterSheet() {
    final visible = _vm.filterSheetVisible;
    if (visible && !_sheetOpen) {
      _openFilterSheet();
    } else if (!visible && _sheetOpen) {
      final sheet = _sheetContext;
      _sheetContext = null;
      if (sheet != null && sheet.mounted) Navigator.pop(sheet);
    }
  }

  Future<void> _openFilterSheet() async {
    _sheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.colors.surface,
      elevation: 4,
      builder: (sheetContext) {
        _sheetContext = sheetContext;
        return ListenableBuilder(
          listenable: _vm,
          builder: (_, _) => RoomFilterBottomSheet(
            filter: _vm.filter,
            onFilterChange: _vm.updateFilter,
            onApply: _vm.applyFilters,
            onClear: _vm.clearFilters,
            onDismiss: _vm.closeFilterSheet,
          ),
        );
      },
    );
    _sheetOpen = false;
    _sheetContext = null;
    _vm.closeFilterSheet();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final filter = vm.filter;

    return Column(
      children: [
        AppTopBar(
          title: 'Find a Room',
          content: SearchHeader(
            keyword: filter.keyword,
            filter: filter,
            onKeywordChange: vm.updateKeyword,
            onSearch: vm.submitSearch,
            onFilterClick: vm.openFilterSheet,
          ),
        ),
        Expanded(
          child: LoaderContent(
            loader: vm.roomLoader,
            skeleton: const ShimmerList(),
            builder: (context, rooms) {
              if (rooms.isEmpty) return const _EmptySearchResult();

              final appending = vm.roomLoader.appending;
              return OnBottomReached(
                onLoadMore: vm.roomLoader.loadMore,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.md,
                    Space.screen,
                    Space.listBottom,
                  ),
                  itemCount: rooms.length + (appending ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: Space.xl),
                  itemBuilder: (context, index) {
                    if (index == rooms.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: Space.lg),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final room = rooms[index];
                    return RoomItemCard(
                      key: ValueKey(room.roomId),
                      isOwnerView: false,
                      images: room.images,
                      roomNumber: room.roomNumber,
                      propertyType: room.propertyType,
                      gender: room.gender,
                      roomType: room.roomType,
                      rent: room.rent,
                      location: '${room.area}, ${room.district}',
                      approved: true,
                      title: room.title,
                      institutionNearby: room.institutionNearby,
                      roomSize: '${room.roomWidth} x ${room.roomHeight}',
                      totalSeats: room.availableSeats,
                      onClick: () => context.push(Routes.roomDetails(room.roomId)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('No rooms found'), Text('Try changing your filters or location.')],
      ),
    );
  }
}
