import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/session_manager.dart';
import '../../../core/network/api_result.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../data/common/page_response.dart';
import '../../../data/dto/chat/chat_dtos.dart';
import '../../../data/dto/tenant/tenant_dtos.dart';
import '../../../data/enums/enums.dart';
import '../../../data/repository/chat_repository.dart';
import '../../../data/repository/file_repository.dart';
import '../../../data/repository/tenant_repository.dart';
import '../../../data/repository/unread_count_repository.dart';
import '../../../domain/model/user.dart';

class ConversationViewModel extends ChangeNotifier {
  ConversationViewModel({
    required this.chatId,
    required this._repo,
    required this._files,
    required this._tenant,
    required this._unreadRepo,
    required this._session,
  }) {
    loader.loadFirst();
    _observeLive();
    _loadRoomBar();
  }

  final int chatId;
  final ChatRepository _repo;
  final FileRepository _files;
  final TenantRepository _tenant;
  final UnreadCountRepository _unreadRepo;
  final SessionManager _session;

  late final loader = PageLoader<ChatMessageResponse>(_loadChat);

  StreamSubscription<ChatMessageResponse>? _liveSub;
  RoomTenantResponse? _roomBar;
  bool _sending = false;
  bool _uploading = false;
  bool _disposed = false;

  User? get me => _session.user;

  RoomTenantResponse? get roomBar => _roomBar;

  bool get sending => _sending;

  bool get uploading => _uploading;

  //==========================================
  // Public methods
  //==========================================

  Future<void> send(String text, {required ValueChanged<String> onError}) async {
    if (text.trim().isEmpty) return;
    _setSending(true);
    switch (await _repo.send(chatId, text.trim())) {
      case ApiSuccess(:final data):
        _appendUnique(data);
      case ApiError(:final message):
        onError(message);
    }
    _setSending(false);
  }

  Future<void> sendImage(XFile file, {required ValueChanged<String> onError}) async {
    _setUploading(true);
    switch (await _files.upload(file, 'chat')) {
      case ApiSuccess(data: final fileKey):
        final body = SendMessageRequest(type: MessageType.IMAGE, attachmentUrl: fileKey);
        switch (await _repo.sendBody(chatId, body)) {
          case ApiSuccess(:final data):
            _appendUnique(data);
          case ApiError(:final message):
            onError(message);
        }
      case ApiError(:final message):
        onError(message);
    }
    _setUploading(false);
  }

  //==========================================
  // Private methods
  //==========================================

  void _observeLive() {
    _liveSub = _repo.liveMessage(chatId).listen((msg) {
      _appendUnique(msg);
      _repo.markRead(chatId);
    }, onError: (_) {});
  }

  Future<ApiResult<PageResponse<ChatMessageResponse>>> _loadChat(int page) async {
    final result = await _repo.messages(chatId);
    switch (result) {
      case ApiSuccess(:final data):
        _repo.markRead(chatId);
        _unreadRepo.updateChatCount();
        return ApiSuccess(data.copyWith(content: data.content.reversed.toList()));
      case ApiError():
        return result;
    }
  }

  Future<void> _loadRoomBar() async {
    final chats = await _repo.list(0);
    if (chats is! ApiSuccess<PageResponse<ChatResponse>>) return;
    final chat = chats.data.content.where((c) => c.id == chatId).firstOrNull;
    if (chat == null) return;

    final room = await _tenant.findRoom(chat.contextId);
    if (room is ApiSuccess<RoomTenantResponse>) {
      _roomBar = room.data;
      _notify();
    }
  }

  void _appendUnique(ChatMessageResponse msg) {
    loader.mutate((current) => current.any((m) => m.id == msg.id) ? current : [...current, msg]);
  }

  void _setSending(bool value) {
    _sending = value;
    _notify();
  }

  void _setUploading(bool value) {
    _uploading = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _liveSub?.cancel();
    loader.dispose();
    super.dispose();
  }
}
