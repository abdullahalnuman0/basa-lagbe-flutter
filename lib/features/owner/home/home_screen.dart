import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/presentation/widgets/room_item_card.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../domain/model/user.dart';
import '../../../main_view_model.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../tenant/home/components/account_dropdown_option.dart';
import 'components/dashboard_info_section.dart';
import 'components/home_shimmer.dart';
import 'home_view_model.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(locator()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final state = vm.state;
    final user = context.select<MainViewModel, User?>((m) => m.user);

    Widget body;
    if (state.isLoading) {
      body = const HomeShimmer();
    } else if (state.error != null && state.properties == null) {
      body = ErrorBox(message: state.error ?? 'Something want wrong', onRetry: vm.loadData);
    } else {
      final properties = switch (state.sortPosition) {
        1 => state.properties?.where((p) => p.approved),
        2 => state.properties?.where((p) => !p.approved),
        _ => state.properties,
      };
      final rooms = [
        for (final property in properties ?? const <PropertyResponse>[])
          for (final room in property.rooms) (property, room),
      ];

      body = PullToRefresh(
        onRefresh: () => vm.loadData(
          onError: () => AppSnackbar.show(
            vm.state.error ?? 'Something want wrong!',
            withDismissAction: true,
            duration: const Duration(days: 1),
          ),
        ),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          itemCount: rooms.length + 2,
          separatorBuilder: (_, _) => const SizedBox(height: Space.md),
          itemBuilder: (context, index) {
            if (index == 0) {
              return DashboardInfoSection(
                userName: user?.fullName,
                summary: state.dashboardSummary,
                sortPosition: state.sortPosition,
                onAddListing: () => context.push(Routes.propertyEditor),
                onSortPositionChange: vm.sortPositionChange,
              );
            }
            if (index == rooms.length + 1) return const SizedBox(height: Space.listBottom);

            final (property, room) = rooms[index - 1];
            return RoomItemCard(
              key: ValueKey(room.id),
              isOwnerView: true,
              images: room.images,
              roomNumber: room.roomNumber,
              propertyType: property.type,
              gender: property.gender,
              roomType: room.type,
              rent: room.rent,
              location: '${property.area}, ${property.district}',
              approved: property.approved,
              title: property.title,
              institutionNearby: property.institutionNearby,
              roomSize: '${room.roomWidth} x ${room.roomWidth}',
              totalSeats: room.availableSeats,
              totalView: room.totalViews,
            );
          },
        ),
      );
    }

    return Column(
      children: [
        AppTopBar(
          title: 'DormEasy',
          appIcon: true,
          actions: [
            AccountDropdownOption(
              user: user,
              onProfile: () => context.push(Routes.user),
              onNotification: () => context.push(Routes.notifications),
              loggedOut: () => context.read<MainViewModel>().loggedOut(),
            ),
          ],
        ),
        Expanded(child: body),
      ],
    );
  }
}
