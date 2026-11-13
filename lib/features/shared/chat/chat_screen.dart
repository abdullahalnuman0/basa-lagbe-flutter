import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/empty_box.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../main_view_model.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../tenant/home/components/account_dropdown_option.dart';
import 'chat_view_model.dart';
import 'components/chat_item_card.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(locator()),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    final loader = context.read<ChatViewModel>().loader;
    final main = context.watch<MainViewModel>();

    return Column(
      children: [
        AppTopBar(
          title: 'Messages',
          subTitle: 'Your conversations',
          actions: [
            AccountDropdownOption(
              user: main.user,
              onProfile: () => context.push(Routes.user),
              onSaved: main.user?.isOwner == true ? null : () => context.push(Routes.savedPosts),
              onNotification: () => context.push(Routes.notifications),
              loggedOut: main.loggedOut,
            ),
          ],
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: loader,
            builder: (context, _) => switch (loader.state) {
              UiLoading() => const ShimmerList(),
              UiError(:final message) => ErrorBox(message: message, onRetry: loader.loadFirst),
              UiSuccess(data: final chats) => PullToRefresh(
                onRefresh: loader.refresh,
                fillViewport: chats.isEmpty,
                child: chats.isEmpty
                    ? const EmptyBox(
                        title: 'No chats yet',
                        subtitle: 'A chat opens when you unlock a book or a tuition application is accepted.',
                        icon: Icons.chat_bubble_outline,
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          Space.screen,
                          Space.md,
                          Space.screen,
                          Space.listBottom,
                        ),
                        itemCount: chats.length,
                        separatorBuilder: (_, _) => const SizedBox(height: Space.listGap),
                        itemBuilder: (context, i) {
                          final chat = chats[i];
                          return ChatItemCard(
                            key: ValueKey(chat.id),
                            chat: chat,
                            onChatClick: () => context.push(Routes.conversation(chat.id)),
                          );
                        },
                      ),
              ),
            },
          ),
        ),
      ],
    );
  }
}
