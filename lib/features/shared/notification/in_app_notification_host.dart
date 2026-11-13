import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/dto/notification/notification_response.dart';
import '../../../ui/theme/theme.dart';

const _autoDismiss = Duration(seconds: 5);

/// Floating glass banner pinned to the top of the app.
///
/// Tapping calls [onClick]; swiping it away or letting it time out calls [onDismiss].
class InAppNotificationHost extends StatelessWidget {
  const InAppNotificationHost({
    super.key,
    required this.banner,
    required this.onClick,
    required this.onDismiss,
  });

  final NotificationResponse? banner;
  final ValueChanged<NotificationResponse> onClick;
  final ValueChanged<int> onDismiss;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          reverseDuration: const Duration(milliseconds: 220),
          switchInCurve: Curves.elasticOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [...previous, ?current],
          ),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.45)),
            child: SlideTransition(
              position: Tween(begin: const Offset(0, -2), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: banner == null
              ? const SizedBox.shrink()
              : _NotificationBanner(
                  key: ValueKey(banner!.id),
                  noty: banner!,
                  onClick: onClick,
                  onDismiss: onDismiss,
                ),
        ),
      ),
    );
  }
}

class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner({
    super.key,
    required this.noty,
    required this.onClick,
    required this.onDismiss,
  });

  final NotificationResponse noty;
  final ValueChanged<NotificationResponse> onClick;
  final ValueChanged<int> onDismiss;

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  Offset _offset = Offset.zero;
  Animation<Offset>? _settleAnim;
  Timer? _timer;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // a light buzz when it shows up
    HapticFeedback.selectionClick();
    _settle.addListener(() {
      final a = _settleAnim;
      if (a != null) setState(() => _offset = a.value);
    });
    _armTimer();
  }

  // auto dismiss; holding the banner pauses the timer
  void _armTimer() {
    _timer?.cancel();
    _timer = Timer(_autoDismiss, () => _dismiss());
  }

  void _dismiss() {
    if (_gone) return;
    _gone = true;
    widget.onDismiss(widget.noty.id);
  }

  Future<void> _animateTo(Offset target, {Curve curve = Curves.easeOut, Duration? duration}) async {
    _settle.duration = duration ?? const Duration(milliseconds: 150);
    _settleAnim = Tween(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _settle, curve: curve));
    await _settle.forward(from: 0);
  }

  Future<void> _onDragEnd(Size size) async {
    final dismissX = size.width * 0.35;
    const dismissY = 48.0;
    if (_offset.dx.abs() > dismissX) {
      await _animateTo(Offset(_offset.dx.sign * size.width * 1.2, _offset.dy));
      _dismiss();
    } else if (_offset.dy < -dismissY) {
      await _animateTo(Offset(_offset.dx, -(size.height + 200)));
      _dismiss();
    } else {
      await _animateTo(
        Offset.zero,
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 350),
      );
      _armTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = context.appColors.background;
    final typos = context.typos;
    final noty = widget.noty;
    const radius = BorderRadius.all(Radius.circular(22));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // fade gradually as it's pushed sideways
        final progress = width == 0 ? 0.0 : (_offset.dx.abs() / width).clamp(0.0, 1.0);

        return Transform.translate(
          offset: _offset,
          child: Opacity(
            opacity: 1 - progress * 0.8,
            child: GestureDetector(
              onTap: () {
                _timer?.cancel();
                widget.onClick(noty);
              },
              onPanStart: (_) {
                _timer?.cancel();
                _settle.stop();
              },
              onPanUpdate: (d) => setState(() {
                // it can be pulled up, never down
                _offset = Offset(
                  _offset.dx + d.delta.dx,
                  (_offset.dy + d.delta.dy).clamp(-9999, 0),
                );
              }),
              onPanEnd: (_) => _onDragEnd(context.size ?? Size(width, 64)),
              onPanCancel: () => _onDragEnd(context.size ?? Size(width, 64)),
              child: Semantics(
                liveRegion: true,
                container: true,
                child: CustomPaint(
                  foregroundPainter: _GlassBorderPainter(radius),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        width: double.infinity,
                        color: colors.onSurface.withValues(alpha: 0.55),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary.withValues(alpha: 0.18),
                              ),
                              child: Icon(Icons.notifications_rounded, color: colors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    noty.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: typos.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: background,
                                    ),
                                  ),
                                  if (noty.body != null && noty.body!.trim().isNotEmpty)
                                    Text(
                                      noty.body!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: typos.bodySmall?.copyWith(
                                        color: background.withValues(alpha: 0.75),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassBorderPainter extends CustomPainter {
  const _GlassBorderPainter(this.radius);

  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0.10)],
      ).createShader(rect);
    canvas.drawRRect(radius.toRRect(rect).deflate(0.5), paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) => oldDelegate.radius != radius;
}
