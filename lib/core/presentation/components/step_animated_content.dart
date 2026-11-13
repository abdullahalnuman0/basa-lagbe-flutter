import 'package:flutter/material.dart';

/// Slides between steps horizontally; [forward] decides the direction.
class StepAnimatedContent<T> extends StatelessWidget {
  const StepAnimatedContent({
    super.key,
    required this.targetState,
    required this.builder,
    this.forward = true,
    this.duration = const Duration(milliseconds: 280),
    this.alignment = Alignment.topLeft,
  });

  final T targetState;
  final bool forward;
  final Duration duration;
  final Alignment alignment;
  final Widget Function(BuildContext context, T state) builder;

  @override
  Widget build(BuildContext context) {
    final currentKey = ValueKey<T>(targetState);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: duration,
        layoutBuilder: (current, previous) =>
            Stack(alignment: alignment, children: [...previous, ?current]),
        transitionBuilder: (child, animation) {
          final incoming = child.key == currentKey;
          final begin = incoming ? Offset(forward ? 1 : -1, 0) : Offset(forward ? -1 : 1, 0);
          return SlideTransition(
            position: Tween(begin: begin, end: Offset.zero).animate(animation),
            child: child,
          );
        },
        child: KeyedSubtree(key: currentKey, child: builder(context, targetState)),
      ),
    );
  }
}
