import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/app_card.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/empty_box.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../core/utils/format.dart';
import '../../../data/dto/chat/chat_dtos.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'components/input_section.dart';
import 'components/message_bubble.dart';
import 'components/room_bar.dart';
import 'conversation_view_model.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key, required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationViewModel(
        chatId: chatId,
        repo: locator(),
        files: locator(),
        tenant: locator(),
        unreadRepo: locator(),
        session: locator(),
      ),
      child: const _ConversationView(),
    );
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView();

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final _listController = ScrollController();
  int _shownCount = 0;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ConversationViewModel vm) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) vm.sendImage(file, onError: AppSnackbar.show);
  }

  void _scrollToLatest(int count) {
    if (count == _shownCount) return;
    _shownCount = count;
    if (count == 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      _listController.animateTo(
        _listController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConversationViewModel>();
    final loader = vm.loader;
    final roomBar = vm.roomBar;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Column(
        children: [
          AppTopBar(title: 'Chat', onBack: context.pop),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: loader,
                    builder: (context, _) => switch (loader.state) {
                      UiLoading() => const ShimmerList(),
                      UiError(:final message) => ErrorBox(
                        message: message,
                        onRetry: loader.loadFirst,
                      ),
                      UiSuccess(data: final messages) => PullToRefresh(
                        onRefresh: loader.refresh,
                        fillViewport: messages.isEmpty,
                        child: _messageList(messages, vm.me?.id),
                      ),
                    },
                  ),
                ),
                if (roomBar != null)
                  Positioned(top: 0, left: 0, right: 0, child: RoomBar(room: roomBar)),
              ],
            ),
          ),
          const AppDivider(),
          InputSection(
            uploading: vm.uploading,
            sending: vm.sending,
            onMessageSend: (text) => vm.send(text, onError: AppSnackbar.show),
            onSelectImage: () => _pickImage(vm),
          ),
        ],
      ),
    );
  }

  Widget _messageList(List<ChatMessageResponse> messages, int? myId) {
    _scrollToLatest(messages.length);

    if (messages.isEmpty) {
      return const EmptyBox(
        title: 'No messages yet',
        subtitle: 'Say hello to start the conversation.',
        icon: Icons.chat_bubble_outline,
      );
    }

    return ListView.separated(
      controller: _listController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Space.screen),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
      itemBuilder: (context, i) {
        final msg = messages[i];
        return MessageBubble(
          key: ValueKey(msg.id),
          message: msg,
          timestamp: formatDateTime(msg.createdAt),
          own: msg.senderId == myId,
        );
      },
    );
  }
}
