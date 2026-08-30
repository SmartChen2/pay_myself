import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../state/app_state_scope.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import '../utils/storage.dart';
import '../widgets/status_bar.dart';
import '../widgets/icons.dart';
import '../models/focus_session.dart';
import '../i18n/strings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final p = AppPalette.of(context);
    final totalEarnings = state.totalEarned;
    final totalMinutes = state.history.fold<int>(0, (s, e) => s + e.durationMinutes);

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const IosStatusBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                children: [
                  Text(
                    context.t('profile.title'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: p.foreground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // avatar card — 头像可点上传,昵称可点编辑
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [p.goldSoft, p.goldSoft.withOpacity(0.5)],
                      ),
                      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      border: Border.all(color: p.gold.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        // 头像(点击上传图片)
                        GestureDetector(
                          onTap: () => _pickAvatar(context, state),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _avatarCircle(context, p, state),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: p.card,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: p.gold.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: AppShadows.shadow1,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 11,
                                    color: p.gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 昵称(点击编辑)+ 累计收益
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _editNickname(context, state),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _displayNick(context, state),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: p.foreground,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: p.mutedForeground,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    CoinIcon(size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.t('profile.total', [Format.yuan(totalEarnings)]),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: p.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  // stats
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          p: p,
                          label: context.t('profile.total.focus'),
                          value: Format.minLabel(totalMinutes),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStat(
                          p: p,
                          label: context.t('profile.available'),
                          value: Format.yuan(state.balance),
                          gold: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _Section(
                    p: p,
                    title: context.t('profile.section.prefs'),
                    children: [
                      _SettingTile(
                        p: p,
                        title: context.t('profile.language'),
                        trailing: _LanguageBadge(
                          code: state.localeOverride,
                          effective: state.effectiveLanguageCode,
                          p: p,
                        ),
                        onTap: () => _editLanguage(context, state),
                      ),
                      _SettingTile(
                        p: p,
                        title: context.t('profile.skin'),
                        trailing: _SkinBadge(skin: state.skin, p: p),
                        onTap: () => _editSkin(context, state),
                      ),
                      _SettingTile(
                        p: p,
                        title: context.t('profile.rain.style'),
                        trailing: _RainStyleBadge(style: state.rainStyle, p: p),
                        onTap: () => _editRainStyle(context, state),
                      ),
                      _SettingTile(
                        p: p,
                        title: context.t('profile.daily.goal'),
                        trailing: Text(
                          Format.yuan(state.dailyGoalYuan),
                          style: TextStyle(
                            color: p.mutedForeground,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () => _editDailyGoal(context, state),
                      ),
                      _SettingTile(
                        p: p,
                        title: context.t('profile.rain.density'),
                        trailing: Text(
                          '${state.coinRainDensity}',
                          style: TextStyle(
                            color: p.mutedForeground,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () => _editCoinRainDensity(context, state),
                      ),
                      _SettingTile(
                        p: p,
                        title: context.t('profile.sound'),
                        trailing: Switch(
                          value: state.soundEnabled,
                          onChanged: (v) => state.setSoundEnabled(v),
                          activeColor: p.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _Section(
                    p: p,
                    title: context.t('profile.section.about'),
                    children: [
                      _SettingTile(
                        p: p,
                        title: context.t('profile.version'),
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(
                            color: p.mutedForeground,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _SettingTile(
                        p: p,
                        title: context.t('profile.feedback'),
                        trailing: CustomPaint(
                          size: const Size.square(16),
                          painter: _Chevron(color: p.mutedForeground),
                        ),
                        onTap: () => _showFeedback(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 头像圆形:有图片显示图片,否则显示昵称首字
  Widget _avatarCircle(BuildContext context, AppPalette p, AppState state) {
    final path = state.avatarPath;
    if (path != null && path.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(path),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _initialAvatar(context, p, state),
        ),
      );
    }
    return _initialAvatar(context, p, state);
  }

  /// 默认头像:金色圆 + 昵称首字(空昵称时显示 i18n 默认词)
  Widget _initialAvatar(BuildContext context, AppPalette p, AppState state) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: p.gold,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initialOf(context, state.nickname),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: p.isDark ? p.goldDark : p.foreground,
        ),
      ),
    );
  }

  /// 当前应显示的昵称:用户设了就用,空则回退到 i18n 默认词。
  String _displayNick(BuildContext context, AppState state) =>
      state.nickname.isEmpty
          ? context.t('profile.nickname.default')
          : state.nickname;

  /// 取昵称首字(支持 emoji / 组合字符),空则返回 i18n 默认词
  /// (英文为 "Me",取首字 "M";中文为 "我")。
  String _initialOf(BuildContext context, String nick) {
    if (nick.isEmpty) {
      final fallback = context.t('profile.nickname.default');
      final runes = fallback.runes;
      return runes.isEmpty ? '?' : String.fromCharCode(runes.first);
    }
    final runes = nick.runes;
    return runes.isEmpty ? '?' : String.fromCharCode(runes.first);
  }

  /// 选图上传头像(本地持久化)
  Future<void> _pickAvatar(BuildContext context, AppState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final srcPath = result.files.single.path;
    if (srcPath == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('profile.avatar.fail.path'))),
      );
      return;
    }
    final dest = await Storage.copyAvatar(File(srcPath));
    if (dest == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('profile.avatar.fail.save'))),
      );
      return;
    }
    state.setAvatarPath(dest);
  }

  /// 编辑昵称
  void _editNickname(BuildContext context, AppState state) async {
    final p = AppPalette.of(context);
    final controller = TextEditingController(text: state.nickname);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(context.t('profile.nickname.title'), style: TextStyle(color: p.foreground)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12,
          style: TextStyle(color: p.foreground),
          decoration: InputDecoration(
            hintText: context.t('profile.nickname.hint'),
            hintStyle: TextStyle(color: p.mutedForeground),
            filled: true,
            fillColor: p.input,
            counterStyle: TextStyle(color: p.mutedForeground, fontSize: 11),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('task.edit.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: p.gold,
              foregroundColor: p.foreground,
            ),
            child: Text(context.t('task.edit.save')),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    state.setNickname(controller.text);
  }

  /// 编辑每日赚钱目标
  void _editDailyGoal(BuildContext context, AppState state) async {
    final p = AppPalette.of(context);
    final controller = TextEditingController(
      text: state.dailyGoalYuan.toStringAsFixed(0),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(context.t('profile.goal.title'), style: TextStyle(color: p.foreground)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: p.foreground),
          decoration: InputDecoration(
            prefixText: Format.currencySymbol,
            hintText: context.t('profile.goal.hint'),
            hintStyle: TextStyle(color: p.mutedForeground),
            filled: true,
            fillColor: p.input,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('task.edit.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: p.gold,
              foregroundColor: p.foreground,
            ),
            child: Text(context.t('task.edit.save')),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final v = double.tryParse(controller.text.trim()) ?? 0;
    if (v <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('profile.goal.invalid'))),
      );
      return;
    }
    state.setDailyGoalYuan(v);
  }

  /// 调整金币雨密度(金币数量)
  void _editCoinRainDensity(BuildContext context, AppState state) async {
    final p = AppPalette.of(context);
    var value = state.coinRainDensity;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(context.t('profile.rain.density'), style: TextStyle(color: p.foreground)),
        content: StatefulBuilder(
          builder: (ctx, setInner) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t('profile.rain.density.unit', ['$value']),
                  style: TextStyle(
                    color: p.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('profile.rain.density.hint'),
                  style: TextStyle(color: p.mutedForeground, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: value.toDouble(),
                  min: 2,
                  max: 40,
                  divisions: 38,
                  activeColor: p.gold,
                  onChanged: (v) => setInner(() => value = v.round()),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('task.edit.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: p.gold,
              foregroundColor: p.foreground,
            ),
            child: Text(context.t('task.edit.save')),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    state.setCoinRainDensity(value);
  }

  /// 切换语言:跟随系统 / 中文 / English
  void _editLanguage(BuildContext context, AppState state) async {
    final p = AppPalette.of(context);
    final options = <_LangOption>[
      _LangOption(code: 'auto', label: context.t('lang.auto')),
      _LangOption(code: 'zh', label: context.t('lang.zh')),
      _LangOption(code: 'en', label: context.t('lang.en')),
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: p.card,
        title: Text(context.t('profile.language'), style: TextStyle(color: p.foreground)),
        children: [
          for (final opt in options)
            RadioListTile<String>(
              value: opt.code,
              groupValue: state.localeOverride,
              activeColor: p.gold,
              title: Text(opt.label, style: TextStyle(color: p.foreground)),
              onChanged: (v) {
                if (v != null) state.setLocaleOverride(v);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    );
  }

  /// 切换雨样式:金币雨 / 钞票雨
  void _editRainStyle(BuildContext context, AppState state) async {
    final p = AppPalette.of(context);
    final options = <_RainStyleOption>[
      _RainStyleOption(style: RainStyle.coin, label: context.t('rain.coin')),
      _RainStyleOption(style: RainStyle.banknote, label: context.t('rain.banknote')),
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: p.card,
        title: Text(context.t('profile.rain.style'), style: TextStyle(color: p.foreground)),
        children: [
          for (final opt in options)
            RadioListTile<RainStyle>(
              value: opt.style,
              groupValue: state.rainStyle,
              activeColor: p.gold,
              title: Row(
                children: [
                  Text(opt.label, style: TextStyle(color: p.foreground)),
                  const SizedBox(width: 8),
                  if (opt.style == RainStyle.banknote)
                    BanknoteIcon(width: 22, height: 14)
                  else
                    CoinIcon(size: 18, color: p.gold, darkColor: p.goldDark),
                ],
              ),
              onChanged: (v) {
                if (v != null) state.setRainStyle(v);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    );
  }

  /// 切换显示模式:白色 / 深色 / 护眼
  void _editSkin(BuildContext context, AppState state) async {
    final p = AppPalette.of(context);
    final options = <_SkinOption>[
      _SkinOption(skin: Skin.light, label: context.t('skin.light')),
      _SkinOption(skin: Skin.dark, label: context.t('skin.dark')),
      _SkinOption(skin: Skin.eyecare, label: context.t('skin.eyecare')),
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: p.card,
        title: Text(context.t('profile.skin'), style: TextStyle(color: p.foreground)),
        children: [
          for (final opt in options)
            RadioListTile<Skin>(
              value: opt.skin,
              groupValue: state.skin,
              activeColor: p.gold,
              title: Row(
                children: [
                  _SkinDot(skin: opt.skin, selected: true, p: p),
                  const SizedBox(width: 10),
                  Text(opt.label, style: TextStyle(color: p.foreground)),
                ],
              ),
              onChanged: (v) {
                if (v != null) state.setSkin(v);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    );
  }

  /// 离线应用反馈:复制邮箱,让用户通过邮件联系
  void _showFeedback(BuildContext context) async {
    const email = 'smatrchen@gmail.com';
    await Clipboard.setData(const ClipboardData(text: email));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('profile.feedback.copied', [email])),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String label;
  const _LangOption({required this.code, required this.label});
}

class _RainStyleOption {
  final RainStyle style;
  final String label;
  const _RainStyleOption({required this.style, required this.label});
}

class _SkinOption {
  final Skin skin;
  final String label;
  const _SkinOption({required this.skin, required this.label});
}

/// 显示模式徽章:圆点 + 名称
class _SkinBadge extends StatelessWidget {
  final Skin skin;
  final AppPalette p;
  const _SkinBadge({required this.skin, required this.p});

  String _label(BuildContext c) => switch (skin) {
        Skin.light => c.t('skin.light'),
        Skin.dark => c.t('skin.dark'),
        Skin.eyecare => c.t('skin.eyecare'),
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SkinDot(skin: skin, selected: false, p: p),
        const SizedBox(width: 8),
        Text(
          _label(context),
          style: TextStyle(
            color: p.mutedForeground,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

/// 显示模式圆点:与 tasks/jtasks 页右上角保持一致的颜色
class _SkinDot extends StatelessWidget {
  final Skin skin;
  final bool selected;
  final AppPalette p;
  const _SkinDot({required this.skin, required this.selected, required this.p});

  Color get _color => switch (skin) {
        Skin.light => const Color(0xFFFFFFFF),
        Skin.dark => const Color(0xFF2C2C38),
        Skin.eyecare => const Color(0xFFCCE8CF),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? p.foreground : p.border,
          width: selected ? 2 : 1,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final AppPalette p;
  final String label;
  final String value;
  final bool gold;
  const _MiniStat({required this.p, required this.label, required this.value, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: gold ? p.gold : p.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: p.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final AppPalette p;
  final String title;
  final List<Widget> children;
  const _Section({required this.p, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: p.mutedForeground,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 1, color: p.border, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final AppPalette p;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingTile({
    required this.p,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: onTap == null ? HitTestBehavior.deferToChild : HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: p.cardForeground,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

/// 语言徽章：显示当前生效语言
class _LanguageBadge extends StatelessWidget {
  final String code; // 'auto' / 'zh' / 'en'
  final String effective; // 'zh' / 'en'
  final AppPalette p;
  const _LanguageBadge({required this.code, required this.effective, required this.p});

  String _label(BuildContext c) {
    if (code == 'auto') return c.t('lang.auto');
    return code == 'zh' ? c.t('lang.zh') : c.t('lang.en');
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _label(context),
      style: TextStyle(
        color: p.mutedForeground,
        fontSize: 15,
      ),
    );
  }
}

/// 雨样式徽章：图标 + 名称
class _RainStyleBadge extends StatelessWidget {
  final RainStyle style;
  final AppPalette p;
  const _RainStyleBadge({required this.style, required this.p});

  String _label(BuildContext c) =>
      style == RainStyle.banknote ? c.t('rain.banknote') : c.t('rain.coin');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style == RainStyle.banknote)
          BanknoteIcon(width: 22, height: 14)
        else
          CoinIcon(size: 16, color: p.gold, darkColor: p.goldDark),
        const SizedBox(width: 8),
        Text(
          _label(context),
          style: TextStyle(
            color: p.mutedForeground,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _Chevron extends CustomPainter {
  final Color color;
  _Chevron({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final d = size.width;
    final path = Path()
      ..moveTo(d * 0.35, d * 0.25)
      ..lineTo(d * 0.65, d * 0.5)
      ..lineTo(d * 0.35, d * 0.75);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _Chevron old) => old.color != color;
}
