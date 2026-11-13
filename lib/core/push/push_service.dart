import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../data/repository/user_repository.dart';
import '../data/session_manager.dart';
import '../network/api_result.dart';

const pushChannelId = 'dorameasy_default';
const _tag = 'DoramEasyPush';

/// Push stays inert until android/app/google-services.json is dropped in.
class PushService {
  PushService(this._repo, this._session);

  final UserRepository _repo;
  final SessionManager _session;

  bool? _available;
  StreamSubscription<String>? _tokenSub;

  Future<bool> _ensureFirebase() async {
    if (_available != null) return _available!;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      debugPrint(
        '$_tag: Firebase is not configured - add android/app/google-services.json to enable push. ($e)',
      );
      _available = false;
    }
    return _available!;
  }

  Future<void> registerPushToken() async {
    if (!await _ensureFirebase()) return;
    try {
      // the backend still stores legacy registration tokens, not installation ids
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      debugPrint('$_tag: FCM token acquired; registering with the backend');
      await _send(token);

      // ignore: deprecated_member_use
      _tokenSub ??= FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (_session.accessToken() == null) return;
        _send(token);
      });
    } catch (e) {
      debugPrint('$_tag: Could not obtain an FCM token: $e');
    }
  }

  Future<void> _send(String token) async {
    switch (await _repo.updateFcmToken(token)) {
      case ApiSuccess():
        debugPrint('$_tag: FCM token registered.');
      case ApiError(:final message):
        debugPrint('$_tag: Backend rejected the FCM token.\n->Error: $message');
    }
  }
}
