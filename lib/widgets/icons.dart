import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../utils/format.dart';

/// 金币图标（符号跟随语言：¥ / $）
class CoinIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? darkColor;
  const CoinIcon({super.key, this.size = 16, this.color, this.darkColor});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _CoinPainter(
        base: color ?? p.gold,
        rim: darkColor ?? p.goldDark,
        soft: p.goldLight,
      ),
    );
  }
}

class _CoinPainter extends CustomPainter {
  final Color base, rim, soft;
  _CoinPainter({required this.base, required this.rim, required this.soft});

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    final center = Offset(d / 2, d / 2);
    final r = d / 2;

    // body
    final body = Paint()..color = base;
    canvas.drawCircle(center, r, body);
    // rim
    final rimP = Paint()
      ..color = rim
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.044;
    canvas.drawCircle(center, r * 0.96, rimP);
    // inner ring
    final inner = Paint()
      ..color = rim.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.037;
    canvas.drawCircle(center, r * 0.7, inner);
    // highlight
    final hl = Paint()..color = soft.withOpacity(0.85);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(d * 0.38, d * 0.38), width: r * 0.9, height: r * 0.6),
      hl,
    );

    // ¥ text
    final tp = TextPainter(
      text: TextSpan(
        text: Format.currencySymbol,
        style: TextStyle(
          fontSize: d * 0.5,
          fontWeight: FontWeight.w800,
          color: rim,
          fontFamily: 'SF Pro Display',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(d / 2 - tp.width / 2, d / 2 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) =>
      old.base != base || old.rim != rim || old.soft != soft;
}

/// 钞票图标 (banknote)
class BanknoteIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final Color? stroke;
  const BanknoteIcon({
    super.key,
    this.width = 24,
    this.height = 16,
    this.color,
    this.stroke,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BanknotePainter(
        fill: color ?? AppTokens.noteGreen,
        stroke: stroke ?? AppTokens.noteGreenDark,
      ),
    );
  }
}

class _BanknotePainter extends CustomPainter {
  final Color fill, stroke;
  _BanknotePainter({required this.fill, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(size.height * 0.16),
    );
    // body fill (light green tint)
    final body = Paint()..color = fill.withOpacity(0.16);
    canvas.drawRRect(rrect, body);
    // border
    final border = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.05;
    canvas.drawRRect(rrect, border);
    // inner dashed border
    final dash = Paint()
      ..color = stroke.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.025;
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.16,
        size.width * 0.8,
        size.height * 0.68,
      ),
      Radius.circular(size.height * 0.1),
    );
    _drawDashedRRect(canvas, inner, dash, dashWidth: size.width * 0.05, gap: size.width * 0.04);
    // central circle
    final ring = Paint()
      ..color = stroke.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.04;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.24,
      ring,
    );
    // ¥
    final tp = TextPainter(
      text: TextSpan(
        text: Format.currencySymbol,
        style: TextStyle(
          fontSize: size.height * 0.32,
          fontWeight: FontWeight.w800,
          color: stroke,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
    );
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rrect,
    Paint paint, {
    required double dashWidth,
    required double gap,
  }) {
    // simple approximation: draw small line segments along the perimeter
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BanknotePainter old) =>
      old.fill != fill || old.stroke != stroke;
}

/// 钱包图标 (focus screen)
/// [glow] 光晕强度 0~1,沿钱包轮廓的渐变光晕
class WalletIcon extends StatelessWidget {
  final double width;
  final double height;
  final double glow;
  const WalletIcon({super.key, this.width = 170, this.height = 142, this.glow = 0.5});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WalletPainter(glow: glow),
    );
  }
}

class _WalletPainter extends CustomPainter {
  final double glow;
  _WalletPainter({this.glow = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final gold = AppTokens.darkGold;
    final w = size.width;
    final h = size.height;
    final scale = w / 120;

    final glowR = RRect.fromRectAndRadius(
      Rect.fromLTWH(15 * scale, 30 * scale, 90 * scale, 55 * scale),
      Radius.circular(12 * scale),
    );
    final flapPath = Path()
      ..moveTo(15 * scale, 40 * scale)
      ..cubicTo(
        15 * scale, 12 * scale,
        105 * scale, 12 * scale,
        105 * scale, 40 * scale,
      );

    // 沿钱包轮廓的渐变光晕(模糊描边,跟随呼吸强度)
    final glowRect = Rect.fromLTWH(0, 0, w, h);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * scale)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTokens.goldLight.withOpacity(0.55 * glow),
          gold.withOpacity(0.35 * glow),
          AppTokens.goldLight.withOpacity(0.55 * glow),
        ],
      ).createShader(glowRect);
    canvas.drawRRect(glowR, glowPaint);
    canvas.drawPath(flapPath, glowPaint);

    // body
    final bodyFill = Paint()..color = gold.withOpacity(0.05);
    final bodyStroke = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;
    canvas.drawRRect(glowR, bodyFill);
    canvas.drawRRect(glowR, bodyStroke);

    // flap
    final flapFill = Paint()..color = gold.withOpacity(0.06);
    canvas.drawPath(flapPath, flapFill);
    canvas.drawPath(flapPath, bodyStroke);

    // stitching
    final stitch = Paint()
      ..color = gold.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    final stitchR = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 * scale, 44 * scale, 72 * scale, 32 * scale),
      Radius.circular(8 * scale),
    );
    final p = Path()..addRRect(stitchR);
    for (final m in p.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final n = (d + 4 * scale).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(d, n), stitch);
        d = n + 3 * scale;
      }
    }

    // coin emblem
    final emblem = Paint()
      ..color = gold.withOpacity(0.10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(60 * scale, 60 * scale), 10 * scale, emblem);
    final emblemRing = Paint()
      ..color = gold.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    canvas.drawCircle(Offset(60 * scale, 60 * scale), 10 * scale, emblemRing);

    final tp = TextPainter(
      text: TextSpan(
        text: Format.currencySymbol,
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w700,
          color: gold.withOpacity(0.65),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(60 * scale - tp.width / 2, 60 * scale - tp.height / 2 + 1 * scale),
    );
  }

  @override
  bool shouldRepaint(covariant _WalletPainter old) => old.glow != glow;
}
