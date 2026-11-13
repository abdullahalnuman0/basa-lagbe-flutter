import 'dart:convert';

import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../../core/network/stomp_client.dart';
import '../api/notification_api.dart';
import '../common/page_response.dart';
import '../dto/notification/notification_response.dart';

class NotificationRepository {
  NotificationRepository(this._api, this._stomp);

  final NotificationApi _api;
  final StompClient _stomp;

  Future<ApiResult<PageResponse<NotificationResponse>>> notifications(int page) =>
      safeApiCall(() => _api.list(page, 20));

  Future<int> notificationUnread() async {
    try {
      return (await _api.unreadCount())['unread'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await _api.markRead(id);
    } catch (_) {}
  }

  Future<ApiResult<void>> markAllNotificationsRead() => safeApiCall(() async => _api.markAllRead());

  Stream<NotificationResponse> liveMessage(int userId) async* {
    await for (final raw in _stomp.subscribe('/topic/users/$userId/notifications')) {
      NotificationResponse? noty;
      try {
        noty = NotificationResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        noty = null;
      }
      if (noty != null) yield noty;
    }
  }
}
