import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../main_view_model.dart';
import '../ui/theme/theme.dart';
import 'nav_animation.dart';

class BottomNavItem {
  const BottomNavItem(this.label, this.icon, this.route, {this.badged = false});

  final String label;
  final IconData icon;
  final String route;
  final bool badged;
}

/// Tab host shared by the owner and tenant graphs.
class TabShell extends StatelessWidget {
  const TabShell({
    super.key,
    required this.navigationShell,
    required this.children,
    required this.items,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;
  final List<BottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: RouteFrame(
        bottom: false,
        child: _FadeIndexedStack(index: navigationShell.currentIndex, children: children),
      ),
      bottomNavigationBar: BottomNavigation(
        items: items,
        currentIndex: navigationShell.currentIndex,
        onNavigate: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}

class _FadeIndexedStack extends StatefulWidget {
  const _FadeIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  @override
  void didUpdateWidget(covariant _FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn)),
      child: IndexedStack(
        index: widget.index,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            TickerMode(enabled: i == widget.index, child: widget.children[i]),
        ],
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onNavigate,
  });

  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      elevation: 4,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                _BottomNavigationItem(
                  item: items[i],
                  isSelected: i == currentIndex,
                  onClick: () => onNavigate(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.item,
    required this.isSelected,
    required this.onClick,
  });

  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unreadChat = item.badged ? context.select<MainViewModel, int>((vm) => vm.unreadChat) : 0;
    final color = isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.6);
    const duration = Duration(milliseconds: 200);

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: Badge(
        isLabelVisible: unreadChat > 0,
        label: Text('$unreadChat'),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isSelected ? null : onClick,
            customBorder: const StadiumBorder(),
            child: AnimatedContainer(
              duration: duration,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: color),
                    duration: duration,
                    builder: (_, c, _) => Icon(item.icon, size: 16, color: c),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    style: context.typos.labelMedium!.copyWith(color: color),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
