import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/dto/property/property_dtos.dart';
import '../features/auth/forget/forget_pwd_screen.dart';
import '../features/auth/otp/otp_screen.dart';
import '../features/auth/signin/signing_screen.dart';
import '../features/auth/signup/signup_screen.dart';
import '../features/owner/home/home_screen.dart';
import '../features/owner/listings/listings_screen.dart';
import '../features/owner/property_add_edit/property_editor_screen.dart';
import '../features/owner/property_details/property_details_screen.dart';
import '../features/shared/chat/chat_screen.dart';
import '../features/shared/conversation/conversation_screen.dart';
import '../features/shared/notification/notification_screen.dart';
import '../features/shared/settings/settings_screen.dart';
import '../features/shared/user/user_screen.dart';
import '../features/tenant/home/home_screen.dart';
import '../features/tenant/room_details/room_details_screen.dart';
import '../features/tenant/saved_post/saved_post_screen.dart';
import '../features/tenant/search/search_screen.dart';
import 'bottom_navigation.dart';
import 'nav_animation.dart';
import 'routes.dart';

GoRouter buildAuthRouter() {
  return GoRouter(
    initialLocation: Routes.login,
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => pushPage(state, const SigningScreen(), safeArea: false),
      ),
      GoRoute(
        path: Routes.signup,
        pageBuilder: (context, state) => pushPage(state, const SignupScreen(), safeArea: false),
      ),
      GoRoute(
        path: Routes.otp,
        pageBuilder: (context, state) {
          final args = state.extra is OtpArgs ? state.extra! as OtpArgs : const OtpArgs('');
          return pushPage(
            state,
            OtpScreen(email: args.email, recover: args.isRecovery),
            safeArea: false,
          );
        },
      ),
      GoRoute(
        path: Routes.forgetPassword,
        pageBuilder: (context, state) => pushPage(state, const ForgetPwdScreen(), safeArea: false),
      ),
    ],
  );
}

const _ownerTabs = [
  BottomNavItem('Home', Icons.dashboard_outlined, Routes.home),
  BottomNavItem('Listing', Icons.location_city_outlined, Routes.listings),
  BottomNavItem('Chat', Icons.chat_bubble_outline, Routes.chat, badged: true),
  BottomNavItem('Settings', Icons.settings_outlined, Routes.settings),
];

const _tenantTabs = [
  BottomNavItem('Home', Icons.dashboard_outlined, Routes.home),
  BottomNavItem('Search', Icons.search_outlined, Routes.search),
  BottomNavItem('Chat', Icons.chat_bubble_outline, Routes.chat, badged: true),
  BottomNavItem('Settings', Icons.settings_outlined, Routes.settings),
];

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);

StatefulShellRoute _tabs(List<BottomNavItem> items, List<Widget> screens) {
  return StatefulShellRoute(
    builder: (context, state, shell) => shell,
    navigatorContainerBuilder: (context, shell, children) =>
        TabShell(navigationShell: shell, items: items, children: children),
    branches: [for (var i = 0; i < items.length; i++) _branch(items[i].route, screens[i])],
  );
}

List<RouteBase> _sharedRoutes() => [
  GoRoute(path: Routes.user, pageBuilder: (context, state) => pushPage(state, const UserScreen())),
  GoRoute(
    path: Routes.notifications,
    pageBuilder: (context, state) => pushPage(state, const NotificationScreen()),
  ),
  GoRoute(
    path: '/conversation/:id',
    pageBuilder: (context, state) =>
        pushPage(state, ConversationScreen(chatId: int.parse(state.pathParameters['id']!))),
  ),
];

GoRouter buildOwnerRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      _tabs(_ownerTabs, const [
        OwnerHomeScreen(),
        ListingsScreen(),
        ChatScreen(),
        SettingsScreen(),
      ]),
      ..._sharedRoutes(),
      GoRoute(
        path: Routes.propertyEditor,
        pageBuilder: (context, state) => pushPage(
          state,
          PropertyEditorScreen(
            updateProperty: state.extra is PropertyResponse
                ? state.extra! as PropertyResponse
                : null,
          ),
        ),
      ),
      GoRoute(
        path: '/property/:id',
        pageBuilder: (context, state) => pushPage(
          state,
          PropertyDetailsScreen(propertyId: int.parse(state.pathParameters['id']!)),
        ),
      ),
    ],
  );
}

GoRouter buildTenantRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      _tabs(_tenantTabs, const [
        TenantHomeScreen(),
        SearchScreen(),
        ChatScreen(),
        SettingsScreen(),
      ]),
      ..._sharedRoutes(),
      GoRoute(
        path: '/room/:id',
        pageBuilder: (context, state) =>
            pushPage(state, RoomDetailsScreen(roomId: int.parse(state.pathParameters['id']!))),
      ),
      GoRoute(
        path: Routes.savedPosts,
        pageBuilder: (context, state) => pushPage(state, const SavedPostScreen()),
      ),
    ],
  );
}
