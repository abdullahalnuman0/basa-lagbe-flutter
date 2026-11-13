import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AppIcons {
  static const logo = 'assets/icons/logo.svg';
  static const email = 'assets/icons/solar_email.svg';
  static const eyeClosed = 'assets/icons/solar_eye_closed.svg';
  static const lockKeyhole = 'assets/icons/solar_lock_keyhole.svg';
  static const phone = 'assets/icons/solar_phone.svg';
  static const user = 'assets/icons/solar_user.svg';
}

/// Tintable svg icon, behaves like [Icon] and picks up the ambient [IconTheme].
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, this.size, this.color, this.semanticLabel});

  final String asset;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final s = size ?? iconTheme.size ?? 24;
    final c = color ?? iconTheme.color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: s,
      height: s,
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: s,
          height: s,
          semanticsLabel: semanticLabel,
          colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
        ),
      ),
    );
  }
}
