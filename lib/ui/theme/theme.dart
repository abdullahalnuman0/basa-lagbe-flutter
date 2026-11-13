import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

const _danger = danger;

const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF0A6C64),
  onPrimary: Color(0xFF003733),
  primaryContainer: Color(0xFF005049),
  onPrimaryContainer: Color(0xFF7AF5E8),
  secondary: Color(0xFFB8CCC8),
  onSecondary: Color(0xFF233331),
  secondaryContainer: Color(0xFF4A4458),
  onSecondaryContainer: Color(0xFFE8DEF8),
  tertiary: Color(0xFFB9C6EA),
  onTertiary: Color(0xFF27304A),
  tertiaryContainer: Color(0xFF633B48),
  onTertiaryContainer: Color(0xFFFFD8E4),
  surface: Color(0xFF1E293B),
  onSurface: softWhite,
  surfaceContainerHighest: Color(0xFF36343B),
  surfaceContainerHigh: Color(0xFF2B2930),
  surfaceContainer: Color(0xFF181829),
  surfaceContainerLow: Color(0xFF1D1B20),
  surfaceContainerLowest: Color(0xFF0F0D13),
  onSurfaceVariant: Color(0xFFC0CCC9),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  outline: Color(0xFF647875),
  outlineVariant: Color(0xFF49454F),
  inverseSurface: Color(0xFFE6E0E9),
  onInverseSurface: Color(0xFF322F35),
  inversePrimary: Color(0xFF6750A4),
);

const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0A6C64),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF8AF3E7),
  onPrimaryContainer: Color(0xFF00201D),
  secondary: Color(0xFF506360),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE8DEF8),
  onSecondaryContainer: Color(0xFF1D192B),
  tertiary: Color(0xFF59627D),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD8E4),
  onTertiaryContainer: Color(0xFF31111D),
  surface: softWhite,
  onSurface: softBlack,
  surfaceContainerHighest: Color(0xFFE6E0E9),
  surfaceContainerHigh: Color(0xFFECE6F0),
  surfaceContainer: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF7F2FA),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  onSurfaceVariant: Color(0xFF404947),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  outline: Color(0xFF707976),
  outlineVariant: Color(0xFFCAC4D0),
  inverseSurface: Color(0xFF322F35),
  onInverseSurface: Color(0xFFF5EFF7),
  inversePrimary: Color(0xFFD0BCFF),
);

/// Background colours differ from surface in dark mode, so they live outside the scheme.
const _darkBackground = Color(0xFF0F172A);
const _lightBackground = softWhite;

@immutable
class CampusSafeSpaceCardColor {
  const CampusSafeSpaceCardColor(this.start, this.end);

  final Color start;
  final Color end;
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.accent,
    required this.cardBorder,
    required this.track,
    required this.campusSafeCard,
    required this.background,
    required this.surfaceVariant,
    required this.isDark,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color accent;
  final Color cardBorder;
  final Color track;
  final CampusSafeSpaceCardColor campusSafeCard;
  final Color background;
  final Color surfaceVariant;
  final bool isDark;

  static final dark = AppColors(
    success: mintBright,
    warning: amberBright,
    danger: dangerBright,
    accent: coral,
    cardBorder: Colors.white.withValues(alpha: 0.06),
    track: Colors.white.withValues(alpha: 0.08),
    campusSafeCard: const CampusSafeSpaceCardColor(Color(0xFF087265), Color(0xFF1E1E4D)),
    background: _darkBackground,
    surfaceVariant: const Color(0xFF334155),
    isDark: true,
  );

  static final light = AppColors(
    success: mint,
    warning: amber,
    danger: _danger,
    accent: const Color(0xFFE0507A),
    cardBorder: const Color(0xFF16162A).withValues(alpha: 0.06),
    track: const Color(0xFF16162A).withValues(alpha: 0.08),
    campusSafeCard: const CampusSafeSpaceCardColor(Color(0xFFF4F4F4), Color(0xFFEAEDF0)),
    background: _lightBackground,
    surfaceVariant: const Color(0xFFDCE5E2),
    isDark: false,
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? accent,
    Color? cardBorder,
    Color? track,
    CampusSafeSpaceCardColor? campusSafeCard,
    Color? background,
    Color? surfaceVariant,
    bool? isDark,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      accent: accent ?? this.accent,
      cardBorder: cardBorder ?? this.cardBorder,
      track: track ?? this.track,
      campusSafeCard: campusSafeCard ?? this.campusSafeCard,
      background: background ?? this.background,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      track: Color.lerp(track, other.track, t)!,
      campusSafeCard: t < 0.5 ? campusSafeCard : other.campusSafeCard,
      background: Color.lerp(background, other.background, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

ThemeData _build(ColorScheme scheme, AppColors ext) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ext.background,
    canvasColor: ext.background,
    textTheme: appTextTheme,
    extensions: [ext],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    appBarTheme: AppBarTheme(
      backgroundColor: ext.background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
    ),
  );
}

final lightTheme = _build(_lightScheme, AppColors.light);
final darkTheme = _build(_darkScheme, AppColors.dark);

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get typos => Theme.of(this).textTheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
