import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/empty_box.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../domain/model/user.dart';
import '../../../main_view_model.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../tenant/home/components/account_dropdown_option.dart';
import '../home/components/listing_item.dart';
import 'listings_view_model.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListingsViewModel(locator()),
      child: const _ListingsView(),
    );
  }
}

class _ListingsView extends StatelessWidget {
  const _ListingsView();

  @override
  Widget build(BuildContext context) {
    final loader = context.read<ListingsViewModel>().properties;
    final user = context.select<MainViewModel, User?>((m) => m.user);

    return Stack(
      children: [
        Column(
          children: [
            AppTopBar(
              title: 'Listings',
              subTitle: 'Your listings',
              actions: [
                AccountDropdownOption(
                  user: user,
                  onProfile: () => context.push(Routes.user),
                  onNotification: () => context.push(Routes.notifications),
                  loggedOut: () => context.read<MainViewModel>().loggedOut(),
                ),
              ],
            ),
            Expanded(
              child: LoaderContent(
                loader: loader,
                skeleton: const ShimmerList(),
                builder: (context, data) => OnBottomReached(
                  onLoadMore: loader.loadMore,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      Space.screen,
                      Space.md,
                      Space.screen,
                      Space.listBottom,
                    ),
                    itemCount: (data.isEmpty ? 1 : data.length) + (loader.appending ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: Space.listGap),
                    itemBuilder: (context, index) {
                      if (data.isEmpty && index == 0) {
                        return const EmptyBox(
                          title: 'Nothing nearby yet',
                          subtitle: 'New Property posts listings will appear here.',
                          icon: Icons.search,
                        );
                      }
                      if (index >= data.length) {
                        return const Padding(
                          padding: EdgeInsets.all(Space.lg),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final property = data[index];
                      return ListingItem(
                        key: ValueKey(property.id),
                        property: property,
                        moreContent: ListingItemBtns(
                          onEdit: () => context.push(Routes.propertyEditor, extra: property),
                          onView: () => context.push(Routes.propertyDetails(property.id)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: Space.screen,
          bottom: Space.screen,
          child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => context.push(Routes.propertyEditor),
            icon: const Icon(Icons.add_outlined, semanticLabel: 'Add'),
            label: const Text('Add Listing'),
          ),
        ),
      ],
    );
  }
}
