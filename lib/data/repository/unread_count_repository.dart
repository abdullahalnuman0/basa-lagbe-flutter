import 'package:flutter/foundation.dart';

import 'chat_repository.dart';
import 'notification_repository.dart';

class UnreadCountRepository extends ChangeNotifier {
  UnreadCountRepository(this._repo, this._notyRepo);

  final ChatRepository _repo;
  final NotificationRepository _notyRepo;

  int _unreadChatCount = 0;
  int _unreadNotificationCount = 0;

  int get unreadChatCount => _unreadChatCount;

  int get unreadNotificationCount => _unreadNotificationCount;

  Future<void> updateChatCount() async {
    _unreadChatCount = await _repo.unreadCount();
    notifyListeners();
  }

  Future<void> updateNotificationCount() async {
    _unreadNotificationCount = await _notyRepo.notificationUnread();
    notifyListeners();
  }

  void incrementUnreadNotyCount([int v = 1]) {
    _unreadNotificationCount += v;
    notifyListeners();
  }

  void decrementUnreadNotyCount([int v = 1]) {
    _unreadNotificationCount -= v;
    notifyListeners();
  }
}
