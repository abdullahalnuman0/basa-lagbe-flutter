import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/theme/theme.dart';

const navDuration = Duration(milliseconds: 600);

/// Push: new page slides in from the right, previous one slides out to the left, both fading.
CustomTransitionPage<void> pushPage(GoRouterState state, Widget child, {bool safeArea = true}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: navDuration,
    reverseTransitionDuration: navDuration,
    child: safeArea ? RouteFrame(child: child) : child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final secondary = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut);
      return SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(curve),
        child: FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween(begin: Offset.zero, end: const Offset(-1, 0)).animate(secondary),
            child: FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0).animate(secondary),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Pages live below the status bar on the app background, like inside a scaffold.
class RouteFrame extends StatelessWidget {
  const RouteFrame({super.key, required this.child, this.bottom = true});

  final Widget child;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.background,
      child: SafeArea(bottom: bottom, child: child),
    );
  }
}
