import 'dart:async';

import 'package:flutter/foundation.dart';

import 'core/data/preferences_manager.dart';
import 'core/data/session_manager.dart';
import 'core/platform/notification_helper.dart';
import 'core/presentation/components/snackbar.dart';
import 'core/push/push_service.dart';
import 'data/dto/notification/notification_response.dart';
import 'data/repository/notification_repository.dart';
import 'data/repository/unread_count_repository.dart';
import 'data/repository/user_repository.dart';
import 'domain/enums/theme_mode.dart';
import 'domain/model/user.dart';

class MainViewModel extends ChangeNotifier {
  MainViewModel({
    required this._userRepo,
    required this._unreadRepo,
    required this._notyRepo,
    required this._preferences,
    required this._session,
    required this._push,
    this.heartbeatInterval = const Duration(seconds: 100),
    this.reconnectDelay = const Duration(seconds: 3),
  }) {
    _preferences.addListener(notifyListeners);
    _session.addListener(_onSessionChanged);
    _unreadRepo.addListener(notifyListeners);
    _onSessionChanged();
  }

  final UserRepository _userRepo;
  final UnreadCountRepository _unreadRepo;
  final NotificationRepository _notyRepo;
  final PreferencesManager _preferences;
  final SessionManager _session;
  final PushService _push;
  final Duration heartbeatInterval;
  final Duration reconnectDelay;

  bool _notificationAllowed = false;

  // ---- Banner state ----
  NotificationResponse? _banner;
  bool _bannerSuppressed = false; // no banner while the notification screen is open
  final _processedNotificationIds = <int>{};

  int? _liveUserId;
  StreamSubscription<NotificationResponse>? _liveSub;
  Timer? _reconnectTimer;
  Timer? _heartbeat;
  bool _disposed = false;

  AppThemeMode get themeMode => _preferences.themeMode;

  bool get notificationAllowed => _notificationAllowed;

  bool get isLoggedIn => _session.isLoggedIn;

  User? get user => _session.user;

  NotificationResponse? get banner => _banner;

  int get unreadChat => _unreadRepo.unreadChatCount;

  int get unreadNotification => _unreadRepo.unreadNotificationCount;

  Future<void> loggedOut() async {
    await _session.clear();
    AppSnackbar.show('Successfully Logged Out.');
  }

  Future<void> onRegisterPush() => _push.registerPushToken();

  Future<void> refreshNotificationStatus() async {
    final allowed = await NotificationHelper.canPostNotifications();
    if (allowed != _notificationAllowed) {
      _notificationAllowed = allowed;
      _notify();
    }
  }

  Future<void> requestNotifications() async {
    await NotificationHelper.requestNotifications();
    await refreshNotificationStatus();
  }

  //========================
  // Session
  //========================

  void _onSessionChanged() {
    final id = _session.user?.id;
    if (_session.isLoggedIn && id != null) {
      _startHeartbeat();
      if (id != _liveUserId) {
        _unreadRepo.updateChatCount();
        _unreadRepo.updateNotificationCount();
      }
    } else {
      _stopHeartbeat();
    }
    _observeLiveNotifications(_session.isLoggedIn ? id : null);
    _notify();
  }

  //========================
  // Live notification
  //========================

  void _observeLiveNotifications(int? userId) {
    if (userId == _liveUserId) return;
    _liveUserId = userId;
    _liveSub?.cancel();
    _liveSub = null;
    _reconnectTimer?.cancel();
    if (userId == null) {
      _banner = null; // drop the banner on logout
      return;
    }
    _subscribe(userId);
  }

  // if the socket drops, subscribe again after a short pause
  void _subscribe(int userId) {
    void retry() {
      _liveSub = null;
      if (_disposed || _liveUserId != userId) return;
      _reconnectTimer = Timer(reconnectDelay, () => _subscribe(userId));
    }

    _liveSub = _notyRepo
        .liveMessage(userId)
        .listen(onIncoming, onError: (_) => retry(), onDone: retry, cancelOnError: true);
  }

  @visibleForTesting
  void onIncoming(NotificationResponse noty) {
    if (noty.read || _bannerSuppressed) return;
    // never process the same notification twice
    if (!_processedNotificationIds.add(noty.id)) return;
    // keep memory bounded
    if (_processedNotificationIds.length > 500) {
      _processedNotificationIds.remove(_processedNotificationIds.first);
    }

    _unreadRepo.incrementUnreadNotyCount();
    if (_preferences.inAppNotification) {
      NotificationHelper.inAppNotyAlert(
        sound: _preferences.inAppNotySound,
        vibration: _preferences.inAppNotyVibration,
      );
      _banner = noty;
      _notify();
    }
  }

  void dismissBanner(int id) {
    // a late timeout must not wipe out a newer notification
    if (_banner?.id == id) {
      _banner = null;
      _notify();
    }
  }

  Future<void> onBannerClick(NotificationResponse noty) async {
    dismissBanner(noty.id);
    await _notyRepo.markNotificationRead(noty.id);
    _unreadRepo.decrementUnreadNotyCount();
  }

  void setBannerSuppressed(bool value) {
    _bannerSuppressed = value;
  }

  //===========================
  // User heartbeat
  //===========================

  void _startHeartbeat() {
    if (_heartbeat?.isActive ?? false) return;
    _userRepo.heartbeat();
    _heartbeat = Timer.periodic(heartbeatInterval, (_) => _userRepo.heartbeat());
  }

  void _stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _preferences.removeListener(notifyListeners);
    _session.removeListener(_onSessionChanged);
    _unreadRepo.removeListener(notifyListeners);
    _liveSub?.cancel();
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    super.dispose();
  }
}
