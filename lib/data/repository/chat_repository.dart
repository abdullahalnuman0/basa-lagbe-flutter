import 'dart:convert';

import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../../core/network/stomp_client.dart';
import '../api/chat_api.dart';
import '../common/page_response.dart';
import '../dto/chat/chat_dtos.dart';

class ChatRepository {
  ChatRepository(this._api, this._stomp);

  final ChatApi _api;
  final StompClient _stomp;

  Future<ApiResult<ChatResponse>> open(int contextId) =>
      safeApiCall(() => _api.open(OpenChatRequest(contextId)));

  Future<ApiResult<PageResponse<ChatResponse>>> list(int page, {int size = 20}) =>
      safeApiCall(() => _api.list(page, size));

  Future<ApiResult<PageResponse<ChatMessageResponse>>> messages(int chatId) =>
      safeApiCall(() => _api.messages(chatId, 0, 50));

  Future<ApiResult<ChatMessageResponse>> send(int chatId, String content) =>
      safeApiCall(() => _api.send(chatId, SendMessageRequest(content: content)));

  Future<ApiResult<ChatMessageResponse>> sendBody(int chatId, SendMessageRequest body) =>
      safeApiCall(() => _api.send(chatId, body));

  Future<void> markRead(int chatId) async {
    try {
      await _api.markRead(chatId);
    } catch (_) {}
  }

  Future<int> unreadCount() async {
    try {
      return (await _api.unreadCount())['unread'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Stream<ChatMessageResponse> liveMessage(int chatId) async* {
    await for (final raw in _stomp.subscribe('/topic/chats/$chatId')) {
      ChatMessageResponse? msg;
      try {
        msg = ChatMessageResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        msg = null;
      }
      if (msg != null) yield msg;
    }
  }
}
