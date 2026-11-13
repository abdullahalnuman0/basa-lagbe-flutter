import 'package:dio/dio.dart';

import '../common/json.dart';
import '../common/page_response.dart';
import '../dto/auth/auth_dtos.dart';
import '../dto/notification/notification_response.dart';

class NotificationApi {
  NotificationApi(this._dio);

  final Dio _dio;

  Future<PageResponse<NotificationResponse>> list(int page, int size) async {
    final res = await _dio.get<Json>(
      'notifications',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(res.data!, NotificationResponse.fromJson);
  }

  Future<Map<String, int>> unreadCount() async {
    final res = await _dio.get<Json>('notifications/unread-count');
    return (res.data ?? {}).map((k, v) => MapEntry(k, asInt(v)));
  }

  Future<MessageResponse> markRead(int id) async {
    final res = await _dio.post<dynamic>('notifications/$id/read');
    return MessageResponse.fromJson(res.data);
  }

  Future<MessageResponse> markAllRead() async {
    final res = await _dio.post<dynamic>('notifications/read-all');
    return MessageResponse.fromJson(res.data);
  }
}
