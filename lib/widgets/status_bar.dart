import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';

/// 仿 iOS 状态栏（设计稿装饰用，真实设备上 SafeArea 已处理系统状态栏）。
/// 仅在桌面端等无真实刘海时给页面顶部一点呼吸感；手机上返回空。
class IosStatusBar extends StatelessWidget {
  final bool dark; // 深色墨水（用于浅色背景）
  const IosStatusBar({super.key, this.dark = true});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fg = p.foreground;
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$hh:$mm',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fg,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            _SignalIcons(color: fg),
          ],
        ),
      ),
    );
  }
}

class _SignalIcons extends StatelessWidget {
  final Color color;
  const _SignalIcons({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(18, 12),
          painter: _SignalBars(color: color),
        ),
        const SizedBox(width: 7),
        CustomPaint(
          size: const Size(16, 12),
          painter: _Wifi(color: color),
        ),
        const SizedBox(width: 7),
        CustomPaint(
          size: const Size(26, 12),
          painter: _Battery(color: color),
        ),
      ],
    );
  }
}

class _SignalBars extends CustomPainter {
  final Color color;
  _SignalBars({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final h = size.height;
    final bw = 3.0;
    final gap = 2.0;
    final heights = [4.0, 6.5, 9.0, 11.5];
    var x = 0.0;
    for (final bh in heights) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, h - bh, bw, bh),
        const Radius.circular(0.75),
      );
      canvas.drawRRect(r, p);
      x += bw + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SignalBars old) => old.color != color;
}

class _Wifi extends CustomPainter {
  final Color color;
  _Wifi({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final path1 = Path()
      ..moveTo(w * 0.5, 2.4)
      ..cubicTo(w * 0.344, 2.4, w * 0.2, 3.3, w * 0.094, 4.9)
      ..lineTo(0.1, 3.4)
      ..cubicTo(w * 0.138, 1.3, w * 0.3125, 0, w * 0.5, 0)
      ..cubicTo(w * 0.6875, 0, w * 0.8625, 1.3, w * 0.9, 3.4)
      ..lineTo(w * 0.906, 4.9)
      ..cubicTo(w * 0.8, 3.3, w * 0.656, 2.4, w * 0.5, 2.4)
      ..close();
    canvas.drawPath(path1, p);
    final path2 = Path()
      ..moveTo(w * 0.5, 5.9)
      ..cubicTo(w * 0.4, 5.9, w * 0.305, 6.5, w * 0.238, 7.6)
      ..lineTo(w * 0.144, 6)
      ..cubicTo(w * 0.244, 4.4, w * 0.363, 3.5, w * 0.5, 3.5)
      ..cubicTo(w * 0.6375, 3.5, w * 0.756, 4.4, w * 0.856, 6)
      ..lineTo(w * 0.763, 7.6)
      ..cubicTo(w * 0.695, 6.5, w * 0.6, 5.9, w * 0.5, 5.9)
      ..close();
    canvas.drawPath(path2, p);
    canvas.drawCircle(Offset(w * 0.5, 9.8), 2, p);
  }

  @override
  bool shouldRepaint(covariant _Wifi old) => old.color != color;
}

class _Battery extends CustomPainter {
  final Color color;
  _Battery({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, 22, 11),
      const Radius.circular(3),
    );
    canvas.drawRRect(r, p);
    final fill = Paint()..color = color;
    final fillR = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, 19, 8),
      const Radius.circular(1.8),
    );
    canvas.drawRRect(fillR, fill);
    final nub = Paint()..color = color.withOpacity(0.35);
    final nubR = RRect.fromRectAndRadius(
      Rect.fromLTWH(23.5, 3.5, 1.8, 5),
      const Radius.circular(0.9),
    );
    canvas.drawRRect(nubR, nub);
  }

  @override
  bool shouldRepaint(covariant _Battery old) => old.color != color;
}
