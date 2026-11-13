import '../data/dto/notification/notification_response.dart';
import '../data/enums/enums.dart';

abstract final class Routes {
  // --- auth ---
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const forgetPassword = '/forget-password';

  // --- bottom tabs ---
  static const home = '/home';
  static const listings = '/listings';
  static const search = '/search';
  static const chat = '/chat';
  static const settings = '/settings';

  // --- shared ---
  static const user = '/user';
  static const notifications = '/notifications';

  static String conversation(int id) => '/conversation/$id';

  // --- owner ---
  static const propertyEditor = '/property/editor';

  static String propertyDetails(int id) => '/property/$id';

  // --- tenant ---
  static const savedPosts = '/saved';

  static String roomDetails(int roomId) => '/room/$roomId';
}

class OtpArgs {
  const OtpArgs(this.email, {this.isRecovery = false});

  final String email;
  final bool isRecovery;
}

/// Where tapping a notification should take the user, or null if it has no destination.
String? notificationTarget(NotificationResponse noty, {required bool isOwner}) {
  final id = noty.refId;
  if (id == null) return null;
  return switch (noty.refType) {
    NotyRefType.CHAT => Routes.conversation(id),
    NotyRefType.OWNER_POST => isOwner ? Routes.propertyDetails(id) : null,
    NotyRefType.TENANT_POST => isOwner ? null : Routes.roomDetails(id),
    null => null,
  };
}
