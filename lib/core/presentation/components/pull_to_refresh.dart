import 'package:flutter/material.dart';

import '../widgets/error_box.dart';
import '../widgets/page_loader.dart';
import 'snackbar.dart';

/// Pull-to-refresh wrapper. Non scrollable children (empty states etc.) should set
/// [fillViewport] so the gesture still works.
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.fillViewport = false,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final bool fillViewport;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: fillViewport
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: child,
                ),
              ),
            )
          : child,
    );
  }
}

/// Calls [onLoadMore] when the wrapped scrollable gets close to its end.
class OnBottomReached extends StatelessWidget {
  const OnBottomReached({
    super.key,
    required this.onLoadMore,
    required this.child,
    this.threshold = 300,
  });

  final VoidCallback onLoadMore;
  final Widget child;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.axis == Axis.vertical &&
            n.metrics.maxScrollExtent > 0 &&
            n.metrics.extentAfter < threshold) {
          onLoadMore();
        }
        return false;
      },
      child: child,
    );
  }
}

/// Renders a [PageLoader]: skeleton while loading, retry on error, refreshable content on success.
class LoaderContent<T> extends StatefulWidget {
  const LoaderContent({super.key, required this.loader, required this.builder, this.skeleton});

  final PageLoader<T> loader;
  final Widget? skeleton;
  final Widget Function(BuildContext context, List<T> data) builder;

  @override
  State<LoaderContent<T>> createState() => _LoaderContentState<T>();
}

class _LoaderContentState<T> extends State<LoaderContent<T>> {
  @override
  void initState() {
    super.initState();
    widget.loader.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant LoaderContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loader != widget.loader) {
      oldWidget.loader.removeListener(_onChange);
      widget.loader.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.loader.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final error = widget.loader.error;
    if (error != null) {
      AppSnackbar.show(error);
      widget.loader.consumeError();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loader = widget.loader;
    return switch (loader.state) {
      UiLoading() => widget.skeleton ?? const Center(child: CircularProgressIndicator()),
      UiError(:final message) => ErrorBox(message: message, onRetry: loader.loadFirst),
      UiSuccess(:final data) => PullToRefresh(
        onRefresh: loader.refresh,
        child: widget.builder(context, data),
      ),
    };
  }
}
