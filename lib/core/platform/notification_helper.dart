import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin bridge to the bits of the notification system Flutter has no API for.
abstract final class NotificationHelper {
  static const _channel = MethodChannel('dev.example.messseat/notification');

  static Future<bool> canPostNotifications() async {
    try {
      return await _channel.invokeMethod<bool>('canPostNotifications') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod<void>('openNotificationSettings');
    } on Exception {
      await openAppSettings();
    }
  }

  static Future<void> ensurePushChannel() async {
    try {
      await _channel.invokeMethod<void>('ensurePushChannel');
    } on Exception {
      // nothing to do on platforms without channels
    }
  }

  static Future<void> inAppNotyAlert({required bool sound, required bool vibration}) async {
    if (!sound && !vibration) return;
    try {
      await _channel.invokeMethod<void>('alert', {'sound': sound, 'vibration': vibration});
    } on Exception {
      if (vibration) await HapticFeedback.mediumImpact();
    }
  }

  /// Asks for POST_NOTIFICATIONS. A silent denial means "don't ask again", so we send
  /// the user to settings – that's the only way forward.
  static Future<void> requestNotifications() async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      await openNotificationSettings();
      return;
    }
    final result = await Permission.notification.request();
    if (!result.isGranted && result.isPermanentlyDenied) {
      await openNotificationSettings();
    }
  }

  static Future<void> requestPermissionIfNeeded() async {
    await ensurePushChannel();
    final status = await Permission.notification.status;
    if (!status.isGranted) await Permission.notification.request();
  }
}
