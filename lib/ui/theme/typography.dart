import 'package:flutter/material.dart';

TextStyle _style(double size, double lineHeight, FontWeight weight, [double letterSpacing = 0]) =>
    TextStyle(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );

final appTextTheme = TextTheme(
  headlineLarge: _style(30, 36, FontWeight.w800, -0.5),
  headlineMedium: _style(24, 30, FontWeight.w700, -0.3),
  headlineSmall: _style(20, 26, FontWeight.w700),
  titleLarge: _style(20, 26, FontWeight.w700),
  titleMedium: _style(16, 22, FontWeight.w600),
  titleSmall: _style(14, 20, FontWeight.w600),
  bodyLarge: _style(16, 24, FontWeight.w400, 0.15),
  bodyMedium: _style(14, 20, FontWeight.w400, 0.2),
  bodySmall: _style(12, 16, FontWeight.w400, 0.3),
  labelLarge: _style(15, 20, FontWeight.w700, 0.1),
  labelMedium: _style(12, 16, FontWeight.w600, 0.5),
  labelSmall: _style(11, 14, FontWeight.w700, 1.2),
);
