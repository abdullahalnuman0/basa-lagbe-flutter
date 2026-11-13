import 'package:dio/dio.dart';

import '../common/json.dart';
import '../common/page_response.dart';
import '../dto/auth/auth_dtos.dart';
import '../dto/chat/chat_dtos.dart';

class ChatApi {
  ChatApi(this._dio);

  final Dio _dio;

  Future<ChatResponse> open(OpenChatRequest body) async {
    final res = await _dio.post<Json>('chats/open', data: body.toJson());
    return ChatResponse.fromJson(res.data!);
  }

  Future<PageResponse<ChatResponse>> list(int page, int size) async {
    final res = await _dio.get<Json>('chats', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data!, ChatResponse.fromJson);
  }

  Future<PageResponse<ChatMessageResponse>> messages(int id, int page, int size) async {
    final res = await _dio.get<Json>(
      'chats/$id/messages',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(res.data!, ChatMessageResponse.fromJson);
  }

  Future<ChatMessageResponse> send(int id, SendMessageRequest body) async {
    final res = await _dio.post<Json>('chats/$id/messages', data: body.toJson());
    return ChatMessageResponse.fromJson(res.data!);
  }

  Future<MessageResponse> markRead(int id) async {
    final res = await _dio.post<dynamic>('chats/$id/read');
    return MessageResponse.fromJson(res.data);
  }

  Future<Map<String, int>> unreadCount() async {
    final res = await _dio.get<Json>('chats/unread-count');
    return (res.data ?? {}).map((k, v) => MapEntry(k, asInt(v)));
  }
}
