import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../models/focus_session.dart';
import 'icons.dart';

/// 金币雨 / 钞票雨 — 从顶部各位置落下，带 3D 旋转。
/// converge=true: 飞向屏幕中心钱包（专注页）；false: 全屏直落（J人模式完成时）。
/// style=RainStyle.banknote: 切换为钞票样式。
/// 颜色随当前显示模式（palette）变化。
class CoinRain extends StatefulWidget {
  final bool reducedMotion;
  final int density;
  final bool converge;
  final RainStyle style;
  const CoinRain({
    super.key,
    this.reducedMotion = false,
    this.density = 14,
    this.converge = true,
    this.style = RainStyle.coin,
  });

  @override
  State<CoinRain> createState() => _CoinRainState();
}

class _CoinRainState extends State<CoinRain>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late List<_CoinSpec> _specs;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _specs = _buildSpecs();
    if (!widget.reducedMotion) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CoinRain old) {
    super.didUpdateWidget(old);
    if (old.density != widget.density) {
      _specs = _buildSpecs();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_CoinSpec> _buildSpecs() {
    final n = widget.density.clamp(1, 40);
    const durations = [3.2, 3.6, 3.0, 3.9, 3.3, 4.2, 3.1, 3.7, 3.4, 4.0, 3.2, 3.8, 3.5, 4.3];
    return [
      for (var i = 0; i < n; i++)
        _CoinSpec(
          // 在 4..96 之间均匀铺开,保留金币雨错落感
          startX: 4 + (92 * (i + 0.5) / n),
          delay: (i * 0.35).clamp(0.0, 5.0),
          duration: durations[i % durations.length],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) return const SizedBox.shrink();
    final p = AppPalette.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final targetX = w / 2;
            final targetY = h / 2;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (final s in _specs)
                  _buildPiece(s, w, h, targetX, targetY, p),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPiece(
      _CoinSpec s, double w, double h, double targetX, double targetY, AppPalette p) {
    final isBanknote = widget.style == RainStyle.banknote;
    // 金币：30×30；钞票：48×28（纸币长宽比约 1.7:1）
    const coinSize = 30.0;
    const noteW = 48.0;
    const noteH = 28.0;
    final halfW = isBanknote ? noteW / 2 : coinSize / 2;
    final halfH = isBanknote ? noteH / 2 : coinSize / 2;
    final totalMs = (s.duration * 1000).clamp(2000, 5000);
    final delayMs = s.delay * 1000;
    final globalMs = (_ctrl.value * 10000) % 10000;
    var phase = ((globalMs - delayMs) % totalMs) / totalMs;
    if (phase < 0) phase += 1;

    final startX = s.startX / 100 * w;
    final px = widget.converge
        ? _lerp(startX, targetX - halfW, phase)
        : startX;
    // converge: 飞向中心钱包；否则自顶向下贯穿全屏。
    // py 起点拉远到 -halfH*5:确保淡入完成时金币仍在屏幕外,不会在左上角"卡住"。
    final py = widget.converge
        ? _lerp(-halfH * 5, targetY + halfH, phase)
        : _lerp(-halfH * 5, h + halfH * 5, phase);
    final scale = _scalePath(phase);
    final opacity = widget.converge ? _opacityPath(phase) : _opacityPathFall(phase);
    final rotY = 720 * phase * math.pi / 180;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0008)
      ..translate(px, py)
      ..rotateY(rotY)
      ..scale(scale);

    final piece = isBanknote
        ? BanknoteIcon(width: noteW, height: noteH)
        : CoinIcon(size: coinSize, color: p.darkGold, darkColor: p.goldDark);

    return Positioned(
      left: 0,
      top: 0,
      child: Transform(
        transform: matrix,
        alignment: Alignment.topLeft,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: piece,
        ),
      ),
    );
  }

  double _scalePath(double p) {
    const stops = [0.0, 0.15, 0.35, 0.55, 0.75, 0.9, 1.0];
    const vals = [0.5, 0.85, 1.0, 1.0, 0.75, 0.4, 0.15];
    return _interp(p, stops, vals);
  }

  double _opacityPath(double p) {
    // 淡入拉慢到 0.12:金币在屏幕外完成显形,避免左上角"瞬现/卡住"。
    const stops = [0.0, 0.12, 0.35, 0.55, 0.75, 0.9, 1.0];
    const vals = [0.0, 0.9, 0.95, 0.9, 0.65, 0.3, 0.0];
    return _interp(p, stops, vals);
  }

  /// 全屏直落模式：开头淡入、结尾淡出，中间保持高不透明度。
  double _opacityPathFall(double p) {
    const stops = [0.0, 0.12, 0.85, 1.0];
    const vals = [0.0, 0.95, 0.95, 0.0];
    return _interp(p, stops, vals);
  }

  double _interp(double p, List<double> stops, List<double> vals) {
    for (var i = 0; i < stops.length - 1; i++) {
      if (p >= stops[i] && p <= stops[i + 1]) {
        final t = (p - stops[i]) / (stops[i + 1] - stops[i]);
        return vals[i] + (vals[i + 1] - vals[i]) * t;
      }
    }
    return vals.last;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class _CoinSpec {
  final double startX; // percent 0..100
  final double delay; // seconds
  final double duration; // seconds
  const _CoinSpec({
    required this.startX,
    required this.delay,
    required this.duration,
  });
}
