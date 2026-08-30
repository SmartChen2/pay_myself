import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';
import '../utils/format.dart';
import '../utils/sound.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../i18n/strings.dart';
import '../widgets/coin_rain.dart';
import '../widgets/icons.dart';

class FocusPage extends StatefulWidget {
  final String taskId;
  final int durationMinutes;
  const FocusPage({
    super.key,
    required this.taskId,
    required this.durationMinutes,
  });

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage>
    with TickerProviderStateMixin {
  late final AnimationController _breathe;
  late final AnimationController _bump;
  Timer? _timer;
  int _elapsed = 0; // 已专注秒数

  double get _totalReward =>
      _task?.rewardFor(widget.durationMinutes) ?? 0;

  /// 按实际专注时长折算的收益(不超过全额)
  double get _earnings {
    final t = (_elapsed / (widget.durationMinutes * 60)).clamp(0.0, 1.0);
    return _totalReward * t;
  }

  Task? get _task => AppStateScope.of(context, listen: false).findTask(widget.taskId);

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bump = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed += 1;
        _bump.forward(from: 0);
      });
    });
    // 开始任务:播放金钱音效
    final state = AppStateScope.of(context, listen: false);
    if (state.soundEnabled) {
      SoundFx.playMoney();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathe.dispose();
    _bump.dispose();
    super.dispose();
  }

  /// 把一条专注会话记入历史(结束专注 / 提前完成时调用)
  void _recordSession({
    required double reward,
    required int minutes,
    required bool earlyComplete,
  }) {
    final state = AppStateScope.of(context, listen: false);
    final task = _task;
    if (task == null || reward <= 0) return;
    state.completeSession(
      task: task,
      durationMinutes: minutes,
      reward: reward,
      earlyComplete: earlyComplete,
      displayName: task.nameKey != null ? context.t(task.nameKey!) : task.name,
    );
  }

  /// 结束专注：按实际专注时长折算收益
  void _endFocus() {
    _recordSession(
      reward: _earnings,
      minutes: (_elapsed / 60).round().clamp(1, 9999),
      earlyComplete: false,
    );
    final state = AppStateScope.of(context, listen: false);
    if (state.soundEnabled) {
      SoundFx.playMoney();
    }
    Navigator.of(context).pop();
  }

  /// 提前完成：无需确认时长，直接按完整计划时长获得全额收益。
  /// 需弹窗确认；确认后把到账金额以 Snackbar 展示给用户。
  Future<void> _completeEarly() async {
    final p = AppPalette.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(
          context.t('focus.early.dialog.title'),
          style: TextStyle(color: p.foreground),
        ),
        content: Text(
          context.t('focus.early.dialog.msg', [Format.yuan(_totalReward)]),
          style: TextStyle(color: p.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t('duration.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.t('focus.early')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final reward = _totalReward;
    _recordSession(
      reward: reward,
      minutes: widget.durationMinutes,
      earlyComplete: true,
    );
    final state = AppStateScope.of(context, listen: false);
    if (state.soundEnabled) {
      SoundFx.playMoney();
    }
    // 让用户直接看到到账金额(页面即将 pop,Snackbar 挂在根 ScaffoldMessenger 上)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('focus.reward.added', [Format.yuan(reward)])),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final state = AppStateScope.of(context);
    // immersive dark — hide system status bar for full focus
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    final task = _task;
    final totalSeconds = widget.durationMinutes * 60;
    final remaining = (totalSeconds - _elapsed).clamp(0, 1 << 31);
    final reduced = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: p.darkBg,
        body: SafeArea(
          child: Stack(
            children: [
              // radial glow background
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.6),
                      radius: 0.9,
                      colors: [
                        p.darkGold.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // coin rain (behind content)
              Positioned.fill(child: CoinRain(
                reducedMotion: reduced,
                density: state.coinRainDensity,
                style: state.rainStyle,
              )),
              // center content(整体下移,让钱包对齐金币雨汇聚点)
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, 34),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (task != null && task.nameKey != null)
                          ? context.t(task.nameKey!)
                          : (task?.name ?? context.t('focus.default.name')),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.darkInk2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // wallet with breathe glow
                    AnimatedBuilder(
                      animation: _breathe,
                      builder: (context, child) {
                        final s = 1 + 0.06 * _breathe.value;
                        return Transform.scale(
                          scale: s,
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                      child: WalletIcon(
                        width: 170,
                        height: 142,
                        glow: 0.45 + 0.4 * _breathe.value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // earnings with bump
                    AnimatedBuilder(
                      animation: _bump,
                      builder: (context, child) {
                        final s = 1 + 0.05 * _bump.value;
                        return Transform.scale(
                          scale: s,
                          child: child,
                        );
                      },
                      child: Text(
                        Format.yuan(_earnings),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: p.darkGold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Format.clock(remaining),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: AppTokens.darkInk3,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                  ),
                ),
              ),
              // 右上角:金币雨 / 钞票雨 切换(与"我的"页面 rainStyle 一致)
              Positioned(
                top: 8,
                right: 16,
                child: GestureDetector(
                  onTap: () => state.setRainStyle(
                    state.rainStyle == RainStyle.coin
                        ? RainStyle.banknote
                        : RainStyle.coin,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTokens.darkBorder),
                    ),
                    child: Tooltip(
                      // 提示点击后切换到的样式
                      message: state.rainStyle == RainStyle.coin
                          ? context.t('rain.banknote')
                          : context.t('rain.coin'),
                      child: state.rainStyle == RainStyle.coin
                          ? const CoinIcon(
                              size: 26,
                              color: AppTokens.darkGold,
                            )
                          : const BanknoteIcon(
                              width: 30,
                              height: 20,
                              color: AppTokens.darkGold,
                            ),
                    ),
                  ),
                ),
              ),
              // end + early-finish buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _endFocus,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTokens.darkInk2,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                            side: BorderSide(color: AppTokens.darkBorder),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: Text(context.t('focus.end')),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _completeEarly,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTokens.darkGold,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                            side: BorderSide(color: AppTokens.darkGold),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(context.t('focus.early')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
