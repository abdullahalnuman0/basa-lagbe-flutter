import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_event.dart';
import 'signup/password_requirements.dart';
import 'signup/password_strength.dart';

abstract class BaseAuthViewModel<S> extends ChangeNotifier {
  BaseAuthViewModel(this._state);

  final _events = StreamController<AuthEvent>.broadcast();
  bool _disposed = false;
  S _state;

  S get state => _state;

  @protected
  set state(S value) {
    _state = value;
    notifyListeners();
  }

  Stream<AuthEvent> get events => _events.stream;

  @protected
  void emit(AuthEvent event) {
    if (!_disposed) _events.add(event);
  }

  @protected
  PasswordStrength calculatePasswordStrength(PasswordRequirements requirements, String password) {
    if (password.isEmpty) return PasswordStrength.empty;

    final score = [
      requirements.hasMinLength,
      requirements.hasUppercase,
      requirements.hasNumber,
      requirements.hasSpacialChar,
    ].where((met) => met).length;

    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.medium,
      4 => PasswordStrength.strong,
      _ => PasswordStrength.empty,
    };
  }

  @protected
  String passwordMessage(PasswordRequirements rqm) {
    final missing = [
      if (!rqm.hasMinLength) 'at least 8 characters',
      if (!rqm.hasUppercase) '1 uppercase letter',
      if (!rqm.hasNumber) '1 number',
      if (!rqm.hasSpacialChar) '1 special character',
    ];
    return missing.isEmpty ? '' : 'Password must include ${missing.join(', ')}.';
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _events.close();
    super.dispose();
  }
}
