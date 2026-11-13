import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/data/favorites_manager.dart';
import 'core/data/preferences_manager.dart';
import 'core/data/session_manager.dart';
import 'core/di/locator.dart';
import 'core/platform/notification_helper.dart';
import 'data/repository/unread_count_repository.dart';
import 'main_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  NotificationHelper.ensurePushChannel();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionManager>.value(value: locator<SessionManager>()),
        ChangeNotifierProvider<PreferencesManager>.value(value: locator<PreferencesManager>()),
        ChangeNotifierProvider<FavoritesManager>.value(value: locator<FavoritesManager>()),
        ChangeNotifierProvider<UnreadCountRepository>.value(
          value: locator<UnreadCountRepository>(),
        ),
        ChangeNotifierProvider<MainViewModel>(
          create: (_) => MainViewModel(
            userRepo: locator(),
            unreadRepo: locator(),
            notyRepo: locator(),
            preferences: locator(),
            session: locator(),
            push: locator(),
          ),
        ),
      ],
      child: const DormEasyApp(),
    ),
  );
}
