import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../state/app_state_scope.dart';
import '../state/app_state.dart';
import '../models/jtask.dart';
import '../models/focus_session.dart' show Skin;
import '../i18n/strings.dart';
import '../utils/sound.dart';
import '../utils/format.dart';
import '../widgets/status_bar.dart';
import '../widgets/task_edit_sheet.dart' show showJTaskEditSheet;
import '../widgets/coin_rain.dart';
import '../widgets/icons.dart';

/// J人模式 — 结构化待办：设定代币、勾选完成、完成时金币雨 + 金钱音效。
class JTasksPage extends StatefulWidget {
  const JTasksPage({super.key});

  @override
  State<JTasksPage> createState() => _JTasksPageState();
}

class _JTasksPageState extends State<JTasksPage> {
  bool _rainVisible = false;
  Timer? _rainTimer;

  @override
  void dispose() {
    _rainTimer?.cancel();
    super.dispose();
  }

  /// 触发全屏金币雨（不汇聚到一点），3 秒后自动收起。
  void _triggerRain() {
    setState(() => _rainVisible = true);
    _rainTimer?.cancel();
    _rainTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _rainVisible = false);
    });
  }

  void _complete(AppState state, JTask task) {
    state.completeJTask(
      task,
      displayName: task.nameKey != null ? context.t(task.nameKey!) : task.name,
    );
    if (state.soundEnabled) {
      SoundFx.playMoney();
    }
    _triggerRain();
  }

  void _addTask(AppState state) async {
    final res = await showJTaskEditSheet(context);
    if (res == null || res.delete || res.name == null) return;
    state.addJTask(res.name!, res.coins);
  }

  void _editTask(AppState state, JTask task) async {
    final res = await showJTaskEditSheet(context, task: task);
    if (res == null) return;
    if (res.delete) {
      state.removeJTask(task.id);
      return;
    }
    state.updateJTask(task.id, name: res.name, coins: res.coins);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final p = AppPalette.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: p.background,
      body: Stack(
        children: [
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const IosStatusBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                    children: [
                      _Header(p: p),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.t('jmode.section'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: p.mutedForeground,
                            ),
                          ),
                          _AddButton(p: p, onTap: () => _addTask(state)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (state.jtasks.isEmpty)
                        _empty(p)
                      else
                        for (final task in state.jtasks)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: JTaskCard(
                              task: task,
                              onTap: () => _editTask(state, task),
                              onComplete: () => _complete(state, task),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 全屏金币雨（直落、不汇聚到一点）
          if (_rainVisible)
            Positioned.fill(
              child: IgnorePointer(
                child: CoinRain(
                  reducedMotion: reduced,
                  density: state.coinRainDensity,
                  converge: false,
                  style: state.rainStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty(AppPalette p) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: p.mutedForeground.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            context.t('jmode.empty.title'),
            style: TextStyle(color: p.mutedForeground, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('jmode.empty.hint'),
            style: TextStyle(color: p.mutedForeground, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppPalette p;
  const _Header({required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              context.t('jmode.title'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: p.foreground,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SkinDots(),
        ],
      ),
    );
  }
}

/// 右上角三个圆圈：白色 / 深色 / 护眼
class _SkinDots extends StatelessWidget {
  static const _skins = [Skin.light, Skin.dark, Skin.eyecare];

  Color _dotColor(Skin s) => switch (s) {
        Skin.light => const Color(0xFFFFFFFF),
        Skin.dark => const Color(0xFF2C2C38),
        Skin.eyecare => const Color(0xFFCCE8CF),
      };

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final p = AppPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in _skins) ...[
          GestureDetector(
            onTap: () => state.setSkin(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: _dotColor(s),
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.skin == s ? p.foreground : p.border,
                  width: state.skin == s ? 2.5 : 1,
                ),
                boxShadow: state.skin == s
                    ? [BoxShadow(color: p.foreground.withOpacity(0.18), blurRadius: 4, spreadRadius: 1)]
                    : null,
              ),
            ),
          ),
          if (s != _skins.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final AppPalette p;
  final VoidCallback onTap;
  const _AddButton({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: p.gold,
          shape: BoxShape.circle,
          boxShadow: AppShadows.shadowGold,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}

/// J人模式任务卡：左侧名称 + 代币；右侧圆形勾选按钮（完成）。
class JTaskCard extends StatelessWidget {
  final JTask task;
  final VoidCallback onTap; // 点击卡片 = 编辑
  final VoidCallback onComplete; // 勾选 = 完成
  const JTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: p.border),
            boxShadow: AppShadows.shadow1,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.nameKey != null
                          ? context.t(task.nameKey!)
                          : task.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: p.cardForeground,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        CoinIcon(size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '${Format.currencySymbol}${task.coinLabel}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: p.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 勾选按钮
              InkWell(
                onTap: onComplete,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: p.gold, width: 1.8),
                  ),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: const Size.square(16),
                    painter: _CheckPainter(color: p.gold),
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

class _CheckPainter extends CustomPainter {
  final Color color;
  _CheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final d = size.width;
    final path = Path()
      ..moveTo(d * 0.15, d * 0.5)
      ..lineTo(d * 0.42, d * 0.77)
      ..lineTo(d * 0.85, d * 0.27);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.color != color;
}
