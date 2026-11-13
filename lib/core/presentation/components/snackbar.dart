import 'package:flutter/material.dart';

abstract final class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(
    String msg, {
    String? actionLabel,
    VoidCallback? onAction,
    bool withDismissAction = false,
    Duration? duration,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          showCloseIcon: withDismissAction,
          duration:
              duration ??
              (actionLabel == null ? const Duration(seconds: 4) : const Duration(days: 1)),
          action: actionLabel == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
        ),
      );
  }

  static void showWithAction(String msg) =>
      show(msg, withDismissAction: true, duration: const Duration(seconds: 10));
}
