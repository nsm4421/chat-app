import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const displayFontFamily = 'Rix이누아리두리네';

  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: _displayStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      displayMedium: _displayStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: _displayStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineMedium: _displayStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: _displayStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: _displayStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: _displayStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: _displayStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: _displayStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: _displayStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: _displayStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextStyle _displayStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
