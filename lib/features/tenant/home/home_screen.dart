import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/room_item_card.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../core/utils/functions.dart';
import '../../../domain/model/user.dart';
import '../../../main_view_model.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import 'components/accommodate_categories_section.dart';
import 'components/account_dropdown_option.dart';
import 'components/home_info_card.dart';
import 'components/near_by_label.dart';
import 'home_view_model.dart';

class TenantHomeScreen extends StatelessWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(locator(), locator()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    final user = context.select<MainViewModel, User?>((main) => main.user);

    void toSearch() => context.go(Routes.search);

    return Column(
      children: [
        AppTopBar(
          title: 'DormEasy',
          appIcon: true,
          subTitle: greeting(user?.fullName),
          actions: [
            AccountDropdownOption(
              user: user,
              onProfile: () => context.push(Routes.user),
              onSaved: () => context.push(Routes.savedPosts),
              onNotification: () => context.push(Routes.notifications),
              loggedOut: () => context.read<MainViewModel>().loggedOut(),
            ),
          ],
        ),
        Expanded(
          child: LoaderContent(
            loader: vm.loader,
            skeleton: const ShimmerList(),
            builder: (context, rooms) => ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.md,
                Space.screen,
                Space.listBottom,
              ),
              itemCount: rooms.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: Space.listGap),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      CampusSafeSpaceCard(onSearch: toSearch),
                      const SizedBox(height: Space.listGap),
                      AccommodateCategoriesSection(onClick: toSearch),
                      const SizedBox(height: Space.listGap),
                      NearByLabel(onSearch: toSearch),
                    ],
                  );
                }

                final r = rooms[index - 1];
                return RoomItemCard(
                  isOwnerView: false,
                  images: r.images,
                  roomNumber: r.roomNumber,
                  propertyType: r.propertyType,
                  gender: r.gender,
                  roomType: r.roomType,
                  rent: r.rent,
                  location: '${r.area}, ${r.district}',
                  approved: true,
                  title: r.title,
                  institutionNearby: r.institutionNearby,
                  roomSize: '${r.roomWidth} x ${r.roomHeight}',
                  totalSeats: r.availableSeats,
                  onClick: () => context.push(Routes.roomDetails(r.roomId)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
