import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/config.dart';
import 'core/platform/notification_helper.dart';
import 'core/presentation/components/snackbar.dart';
import 'domain/enums/theme_mode.dart';
import 'domain/model/user.dart';
import 'features/shared/notification/in_app_notification_host.dart';
import 'main_view_model.dart';
import 'navigation/app_router.dart';
import 'navigation/routes.dart';
import 'ui/theme/theme.dart';

enum _Graph { auth, owner, tenant, none }

class DormEasyApp extends StatefulWidget {
  const DormEasyApp({super.key});

  @override
  State<DormEasyApp> createState() => _DormEasyAppState();
}

class _DormEasyAppState extends State<DormEasyApp> with WidgetsBindingObserver {
  _Graph? _graph;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshSystemStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSystemStatus();
  }

  void _refreshSystemStatus() {
    if (mounted) context.read<MainViewModel>().refreshNotificationStatus();
  }

  _Graph _graphFor(bool loggedIn, User? user) {
    if (!loggedIn) return _Graph.auth;
    if (user == null) return _Graph.none;
    if (user.isOwner) return _Graph.owner;
    if (user.isTenant) return _Graph.tenant;
    return _Graph.none;
  }

  GoRouter _routerFor(_Graph graph) {
    if (graph == _graph && _router != null) return _router!;
    final old = _router;
    _graph = graph;
    _router = switch (graph) {
      _Graph.auth => buildAuthRouter(),
      _Graph.owner => buildOwnerRouter(),
      _Graph.tenant => buildTenantRouter(),
      _Graph.none => GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
      ),
    };
    if (graph == _Graph.owner || graph == _Graph.tenant) _onSignedIn();
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    return _router!;
  }

  void _onSignedIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<MainViewModel>();
      // Ask for notification permission (Android 13+) and register this device for push.
      await NotificationHelper.requestPermissionIfNeeded();
      await vm.refreshNotificationStatus();
      vm.onRegisterPush();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final graph = _graphFor(vm.isLoggedIn, vm.user);
    final router = _routerFor(graph);
    final mode = switch (vm.themeMode) {
      AppThemeMode.SYSTEM => ThemeMode.system,
      AppThemeMode.LIGHT => ThemeMode.light,
      AppThemeMode.DARK => ThemeMode.dark,
    };

    return MaterialApp.router(
      key: ValueKey(graph),
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      scaffoldMessengerKey: AppSnackbar.messengerKey,
      routerConfig: router,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
          ),
          child: Stack(
            children: [
              ?child,
              if (graph == _Graph.owner || graph == _Graph.tenant)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _BannerLayer(router: router, isOwner: graph == _Graph.owner),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerLayer extends StatelessWidget {
  const _BannerLayer({required this.router, required this.isOwner});

  final GoRouter router;
  final bool isOwner;

  int? _activeChatId() {
    final path = router.routerDelegate.currentConfiguration.uri.path;
    final match = RegExp(r'^/conversation/(\d+)$').firstMatch(path);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final vm = context.watch<MainViewModel>();
        final banner = vm.banner;
        final activeChatId = _activeChatId();
        final suppress =
            banner != null &&
            activeChatId != null &&
            banner.refId == activeChatId &&
            notificationTarget(banner, isOwner: isOwner) == Routes.conversation(activeChatId);

        if (suppress) {
          WidgetsBinding.instance.addPostFrameCallback((_) => vm.dismissBanner(banner.id));
        }

        return InAppNotificationHost(
          banner: suppress ? null : banner,
          onClick: (noty) {
            vm.onBannerClick(noty);
            final target = notificationTarget(noty, isOwner: isOwner);
            if (target != null) router.push(target);
          },
          onDismiss: vm.dismissBanner,
        );
      },
    );
  }
}
