import 'package:flutter/material.dart';
import 'tokens.dart';
import '../models/focus_session.dart';

/// 三套显示模式：白色 / 深色 / 护眼
@immutable
class AppPalette {
  // === 基础表面色 ===
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color input;

  // === 金色系 ===
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color goldSoft;
  final Color goldShadow; // 金色阴影色

  // === 专注屏深色（三模式共用深色沉浸，金币色随模式） ===
  final Color darkBg;
  final Color darkGold;
  final Color darkGoldSoft;

  final bool isDark;

  const AppPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.input,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.goldSoft,
    required this.goldShadow,
    required this.darkBg,
    required this.darkGold,
    required this.darkGoldSoft,
    required this.isDark,
  });

  // === 白色模式（默认） ===
  static const light = AppPalette(
    background: AppTokens.background,
    foreground: AppTokens.foreground,
    card: AppTokens.card,
    cardForeground: AppTokens.cardForeground,
    muted: AppTokens.muted,
    mutedForeground: AppTokens.mutedForeground,
    border: AppTokens.border,
    input: AppTokens.input,
    gold: AppTokens.gold,
    goldLight: AppTokens.goldLight,
    goldDark: AppTokens.goldDark,
    goldSoft: AppTokens.goldSoft,
    goldShadow: Color(0x0DD4A017),
    darkBg: AppTokens.darkBg,
    darkGold: AppTokens.darkGold,
    darkGoldSoft: AppTokens.darkGoldSoft,
    isDark: false,
  );

  // === 深色模式 ===
  static const dark = AppPalette(
    background: Color(0xFF0F0F14),
    foreground: Color(0xFFF2F2F5),
    card: Color(0xFF1A1A22),
    cardForeground: Color(0xFFF2F2F5),
    muted: Color(0xFF24242E),
    mutedForeground: Color(0xFF9A9AA4),
    border: Color(0xFF2C2C38),
    input: Color(0xFF24242E),
    gold: Color(0xFFF0C75E),
    goldLight: Color(0xFFF5D985),
    goldDark: Color(0xFFD4A017),
    goldSoft: Color(0xFF2A2418),
    goldShadow: Color(0x0DF0C75E),
    darkBg: AppTokens.darkBg,
    darkGold: Color(0xFFF0C75E),
    darkGoldSoft: AppTokens.darkGoldSoft,
    isDark: true,
  );

  // === 护眼模式（豆沙绿） ===
  static const eyecare = AppPalette(
    background: Color(0xFFD5E3D0),
    foreground: Color(0xFF2D3A2E),
    card: Color(0xFFEDF3E8),
    cardForeground: Color(0xFF2D3A2E),
    muted: Color(0xFFDCE7D5),
    mutedForeground: Color(0xFF6B7A6C),
    border: Color(0xFFBFD4B8),
    input: Color(0xFFDCE7D5),
    gold: Color(0xFFC9A227),
    goldLight: Color(0xFFDDB84A),
    goldDark: Color(0xFFA8841A),
    goldSoft: Color(0xFFE8E0C5),
    goldShadow: Color(0x0DC9A227),
    darkBg: Color(0xFF0E1410),
    darkGold: Color(0xFFE8C25A),
    darkGoldSoft: Color(0x1FE8C25A),
    isDark: false,
  );

  static AppPalette forSkin(Skin skin) => switch (skin) {
        Skin.light => light,
        Skin.dark => dark,
        Skin.eyecare => eyecare,
      };

  /// 便捷访问：AppPalette.of(context)
  static AppPalette of(BuildContext context) =>
      AppPaletteScope.of(context);
}

/// 暴露当前 palette 给 widget 树
class AppPaletteScope extends InheritedWidget {
  final AppPalette palette;
  const AppPaletteScope({
    super.key,
    required this.palette,
    required super.child,
  });

  static AppPalette of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<AppPaletteScope>();
    return w?.palette ?? AppPalette.light;
  }

  @override
  bool updateShouldNotify(covariant AppPaletteScope oldWidget) =>
      oldWidget.palette != palette;
}
