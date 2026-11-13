import 'package:flutter/material.dart';

import '../../../../core/presentation/components/search_field.dart';
import '../../../../ui/theme/space.dart';
import '../room_search_filter.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.keyword,
    required this.filter,
    required this.onKeywordChange,
    required this.onSearch,
    required this.onFilterClick,
  });

  final String keyword;
  final RoomSearchFilter filter;
  final ValueChanged<String> onKeywordChange;
  final VoidCallback onSearch;
  final VoidCallback onFilterClick;

  @override
  Widget build(BuildContext context) {
    final count = filter.activeFilterCount();

    return Padding(
      padding: const EdgeInsets.only(left: Space.screen, right: Space.screen, bottom: Space.sm),
      child: Row(
        children: [
          Expanded(
            child: SearchField(
              value: keyword,
              onValueChange: onKeywordChange,
              onClear: () {
                onKeywordChange('');
                onSearch();
              },
              placeholder: 'Search rooms...',
              borderRadius: BorderRadius.circular(50),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: keyword.trim().isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: onSearch,
                      tooltip: 'Search',
                      icon: const Icon(Icons.search),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            offset: const Offset(-4, 4),
            child: IconButton(
              onPressed: onFilterClick,
              tooltip: 'Filters',
              icon: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
    );
  }
}
