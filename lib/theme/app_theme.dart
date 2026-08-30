import 'package:flutter/material.dart';
import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppTokens.gold,
        onPrimary: AppTokens.foreground,
        surface: AppTokens.background,
        onSurface: AppTokens.foreground,
      ),
      scaffoldBackgroundColor: AppTokens.background,
    );
    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      dividerTheme: const DividerThemeData(
        color: AppTokens.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkFocus() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.darkGold,
        onPrimary: AppTokens.darkBg,
        surface: AppTokens.darkBg,
        onSurface: AppTokens.darkInk,
      ),
      scaffoldBackgroundColor: AppTokens.darkBg,
    );
    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
    );
  }

  // iOS renders SF Pro automatically (system default). We do not pin a custom
  // family so each platform uses its native system font for best fidelity.

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(letterSpacing: -0.02),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: AppTokens.foreground),
      bodyMedium: base.bodyMedium?.copyWith(color: AppTokens.mutedForeground),
    );
  }
}
