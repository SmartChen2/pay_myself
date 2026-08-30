// PayMe 专注 — Design Tokens
// Primary hue: warm gold (earnings / coin theme)
// Focus screen: deep dark immersive background
// Task list: clean light iOS surface

import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  // === Brand Primary (Gold) ===
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFE8C25A);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldSoft = Color(0xFFF5E6C8);

  // === Light Mode — Task List ===
  static const Color background = Color(0xFFF7F6F2);
  static const Color foreground = Color(0xFF1A1A1F);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A1A1F);
  static const Color muted = Color(0xFFF0EDE5);
  static const Color mutedForeground = Color(0xFF8A8A8E);
  static const Color border = Color(0xFFE5E2DA);
  static const Color input = Color(0xFFF0EDE5);

  // === Dark Mode — Focus Screen ===
  static const Color darkBg = Color(0xFF0B0B0F);
  static const Color darkSurface = Color(0xFF14141A);
  static const Color darkSurface2 = Color(0xFF1E1E26);
  static const Color darkInk = Color(0xFFFFFFFF);
  static const Color darkInk2 = Color(0xA6FFFFFF); // 65%
  static const Color darkInk3 = Color(0x66FFFFFF); // 40%
  static const Color darkBorder = Color(0x14FFFFFF); // 8%
  static const Color darkGold = Color(0xFFF0C75E);
  static const Color darkGoldSoft = Color(0x1FF0C75E); // 12%

  // banknote palette (green)
  static const Color noteGreen = Color(0xFF5BA670);
  static const Color noteGreenDark = Color(0xFF3A7D50);
  static const Color noteGreenDeep = Color(0xFF2E6B3A);

  // === State Colors ===
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4A90D9);

  // === Radius Scale ===
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 16;
  static const double radiusPill = 999;

  // === Spacing ===
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;

  // === Phone frame (desktop/tablet adaptation) ===
  static const double phoneMaxWidth = 440;
}

class AppShadows {
  AppShadows._();

  static const Color goldShadowColor = Color(0x0DD4A017);

  static const List<BoxShadow> shadow1 = [
    BoxShadow(color: Color(0x0A0F1728), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x080F1728), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x0D0F1728),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Color(0x140F1728),
      offset: Offset(0, 24),
      blurRadius: 60,
      spreadRadius: -20,
    ),
  ];

  static const List<BoxShadow> shadowGold = [
    BoxShadow(
      color: goldShadowColor,
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> shadowModal = [
    BoxShadow(
      color: Color(0x1F0F1728),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> shadowOverlay = [
    BoxShadow(
      color: Color(0x400F1728),
      offset: Offset(0, 24),
      blurRadius: 60,
      spreadRadius: -20,
    ),
  ];

  static const List<BoxShadow> shadowGoldGlow = [
    BoxShadow(
      color: Color(0x4DD4A017),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];
}
