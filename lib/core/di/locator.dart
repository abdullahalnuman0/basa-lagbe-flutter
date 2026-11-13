import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/auth_api.dart';
import '../../data/api/chat_api.dart';
import '../../data/api/file_api.dart';
import '../../data/api/notification_api.dart';
import '../../data/api/property_api.dart';
import '../../data/api/tenant_api.dart';
import '../../data/api/user_api.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/chat_repository.dart';
import '../../data/repository/file_repository.dart';
import '../../data/repository/notification_repository.dart';
import '../../data/repository/property_repository.dart';
import '../../data/repository/tenant_repository.dart';
import '../../data/repository/unread_count_repository.dart';
import '../../data/repository/user_repository.dart';
import '../data/favorites_manager.dart';
import '../data/preferences_manager.dart';
import '../data/session_manager.dart';
import '../network/api_client.dart';
import '../network/stomp_client.dart';
import '../push/push_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();

  // --- data ---
  final session = SessionManager(prefs);
  locator
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<SessionManager>(session)
    ..registerSingleton<PreferencesManager>(PreferencesManager(prefs))
    ..registerSingleton<FavoritesManager>(FavoritesManager(prefs));

  // --- network ---
  final client = createApiClient(session, createRefreshDio());
  locator
    ..registerSingleton<Dio>(client)
    ..registerLazySingleton<StompClient>(StompClient.new);

  // --- api ---
  locator
    ..registerLazySingleton(() => AuthApi(client))
    ..registerLazySingleton(() => FileApi(client))
    ..registerLazySingleton(() => PropertyApi(client))
    ..registerLazySingleton(() => TenantApi(client))
    ..registerLazySingleton(() => ChatApi(client))
    ..registerLazySingleton(() => UserApi(client))
    ..registerLazySingleton(() => NotificationApi(client));

  // --- repository ---
  locator
    ..registerLazySingleton(() => AuthRepository(locator(), locator()))
    ..registerLazySingleton(() => FileRepository(locator()))
    ..registerLazySingleton(() => PropertyRepository(locator()))
    ..registerLazySingleton(() => TenantRepository(locator()))
    ..registerLazySingleton(() => ChatRepository(locator(), locator()))
    ..registerLazySingleton(() => NotificationRepository(locator(), locator()))
    ..registerLazySingleton(() => UnreadCountRepository(locator(), locator()))
    ..registerLazySingleton(() => UserRepository(locator()))
    ..registerLazySingleton(() => PushService(locator(), locator()));
}
