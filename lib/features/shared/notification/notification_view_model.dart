import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../data/dto/notification/notification_response.dart';
import '../../../data/repository/notification_repository.dart';
import '../../../data/repository/unread_count_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel(this._notyRepo, this._unreadRepo) {
    loader.loadFirst();
  }

  final NotificationRepository _notyRepo;
  final UnreadCountRepository _unreadRepo;

  late final loader = PageLoader<NotificationResponse>(_notyRepo.notifications);

  Future<void> markRead(int id) async {
    await _notyRepo.markNotificationRead(id);
    _unreadRepo.decrementUnreadNotyCount();
    loader.mutate((list) => [for (final n in list) n.id == id ? n.copyWith(read: true) : n]);
  }

  Future<void> markAll({required ValueChanged<String> onResult}) async {
    switch (await _notyRepo.markAllNotificationsRead()) {
      case ApiSuccess():
        loader.mutate((list) => [for (final n in list) n.copyWith(read: true)]);
        onResult('Marked all as read.');
        _unreadRepo.updateNotificationCount();
      case ApiError(:final message):
        onResult(message);
    }
  }

  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }
}
