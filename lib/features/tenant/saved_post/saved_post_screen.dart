import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/empty_box.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../shared/conversation/components/room_bar_content.dart';
import 'save_post_view_model.dart';

class SavedPostScreen extends StatelessWidget {
  const SavedPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavePostViewModel(locator(), locator()),
      child: const _SavedPostView(),
    );
  }
}

class _SavedPostView extends StatelessWidget {
  const _SavedPostView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavePostViewModel>();
    final state = vm.uiState;

    final Widget content;
    if (state.isLoading && state.rooms.isEmpty) {
      content = const ShimmerList();
    } else if (!state.isLoading && state.error != null) {
      content = ErrorBox(
        message: state.error ?? 'Something want wrong, please try again.',
        onRetry: vm.loadSaveRooms,
      );
    } else if (state.rooms.isEmpty) {
      content = const EmptyBox(
        title: 'No room saved',
        subtitle: "You don't save any rooms.",
        icon: Icons.event_seat,
      );
    } else {
      content = ListView.separated(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.md, Space.screen, Space.listBottom),
        itemCount: state.rooms.length,
        separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
        itemBuilder: (context, index) {
          final r = state.rooms[index];
          return RoomBarContent(
            key: ValueKey(r.roomId),
            room: r,
            onClick: () => context.push(Routes.roomDetails(r.roomId)),
          );
        },
      );
    }

    return Column(
      children: [
        AppTopBar(title: 'Saved', subTitle: 'Your saved rooms', onBack: () => context.pop()),
        Expanded(child: content),
      ],
    );
  }
}
