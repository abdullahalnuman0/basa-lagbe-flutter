import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../core/utils/functions.dart';
import '../../../../data/dto/property/property_dtos.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import 'add_new_listing_btn.dart';
import 'feed_tabs.dart';
import 'over_view_section.dart';
import 'total_listing_label.dart';

class DashboardInfoSection extends StatelessWidget {
  const DashboardInfoSection({
    super.key,
    required this.userName,
    required this.summary,
    required this.sortPosition,
    required this.onAddListing,
    required this.onSortPositionChange,
  });

  final String? userName;
  final OwnerDashboardSummaryResponse? summary;
  final int sortPosition;
  final VoidCallback onAddListing;
  final ValueChanged<int> onSortPositionChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.sm,
        children: [
          PageHeader(
            title: greeting(userName),
            subtitle: 'Manage your rental listings',
            titleStyle: typos.headlineMedium,
            subtitleStyle: typos.bodyMedium,
          ),
          AddNewListingBtn(onClick: onAddListing),
          OverViewSection(
            overViews: [
              OverViewData(
                'Active Listings',
                summary?.activeListings ?? 0,
                Icons.check_circle_outline_rounded,
                colors.primary,
              ),
              OverViewData(
                'Pending Approval',
                summary?.pendingApproval ?? 0,
                Icons.hourglass_empty_rounded,
                colors.error,
              ),
              OverViewData(
                'Available Seats',
                summary?.availableSeats ?? 0,
                Icons.hotel_rounded,
                colors.secondary,
              ),
              OverViewData(
                'Total Rooms',
                summary?.totalRoom ?? 0,
                Icons.meeting_room_rounded,
                colors.tertiary,
              ),
            ],
          ),
          TotalListingLabel(total: summary?.totalRoom ?? 0),
          FeedTabs(
            totalRoom: summary?.totalRoom ?? 0,
            approved: summary?.approvedRoom ?? 0,
            pending: summary?.pendingRoom ?? 0,
            selected: sortPosition,
            onSelect: onSortPositionChange,
          ),
        ],
      ),
    );
  }
}
