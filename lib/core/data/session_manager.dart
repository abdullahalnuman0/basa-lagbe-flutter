import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/dto/auth/auth_dtos.dart';
import '../../data/dto/user/user_response.dart';
import '../../domain/model/user.dart';

class SessionManager extends ChangeNotifier {
  SessionManager(this._prefs) {
    _access = _prefs.getString(_kAccess);
    _refresh = _prefs.getString(_kRefresh);
    _user = _decodeUser(_prefs.getString(_kUser));
  }

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUser = 'user_json';

  final SharedPreferences _prefs;

  String? _access;
  String? _refresh;
  User? _user;

  String? accessToken() => _access;

  String? refreshToken() => _refresh;

  User? get user => _user;

  bool get isLoggedIn => _access != null;

  Future<void> saveSession(AuthResponse auth) async {
    _access = auth.accessToken;
    _refresh = auth.refreshToken;
    _user = auth.user.toDomain();
    await _prefs.setString(_kAccess, auth.accessToken);
    await _prefs.setString(_kRefresh, auth.refreshToken);
    await _prefs.setString(_kUser, jsonEncode(auth.user.toJson()));
    notifyListeners();
  }

  Future<void> updateToken(String newAccess, String newRefresh) async {
    _access = newAccess;
    _refresh = newRefresh;
    await _prefs.setString(_kAccess, newAccess);
    await _prefs.setString(_kRefresh, newRefresh);
  }

  Future<void> updateUser(UserResponse user) async {
    _user = user.toDomain();
    await _prefs.setString(_kUser, jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> clear() async {
    final wasLoggedIn = _access != null || _user != null;
    _access = null;
    _refresh = null;
    _user = null;
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kUser);
    if (wasLoggedIn) notifyListeners();
  }

  static User? _decodeUser(String? raw) {
    if (raw == null) return null;
    try {
      return UserResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>).toDomain();
    } catch (_) {
      return null;
    }
  }
}
