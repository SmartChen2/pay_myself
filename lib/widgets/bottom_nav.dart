import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../i18n/strings.dart';

enum NavKey { tasks, jtasks, shop, history, profile }

class BottomNav extends StatelessWidget {
  final NavKey active;
  final ValueChanged<NavKey> onTap;
  const BottomNav({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: p.card.withOpacity(0.92),
        border: Border(top: BorderSide(color: p.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final k in NavKey.values)
              Expanded(
                child: _NavCell(
                  key: ValueKey(k),
                  item: k,
                  active: k == active,
                  onTap: () => onTap(k),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final NavKey item;
  final bool active;
  final VoidCallback onTap;
  const _NavCell({
    super.key,
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final color = active ? p.gold : p.mutedForeground;
    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Icon(item, color: color),
          const SizedBox(height: 4),
          Text(
            _label(item, context),
            style: TextStyle(
              fontSize: 11,
              height: 1,
              color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _label(NavKey k, BuildContext ctx) => switch (k) {
        NavKey.tasks => ctx.t('nav.pmode'),
        NavKey.jtasks => ctx.t('nav.jmode'),
        NavKey.shop => ctx.t('nav.shop'),
        NavKey.history => ctx.t('nav.history'),
        NavKey.profile => ctx.t('nav.profile'),
      };
}

class _Icon extends StatelessWidget {
  final NavKey item;
  final Color color;
  const _Icon(this.item, {required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(20),
      painter: _NavIcon(item, color: color),
    );
  }
}

class _NavIcon extends CustomPainter {
  final NavKey item;
  final Color color;
  _NavIcon(this.item, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    switch (item) {
      case NavKey.tasks:
        // flow waves — 三道流水波纹，象征自由 / 专注 / 心流
        final wave1 = Path()
          ..moveTo(3, 6)
          ..quadraticBezierTo(6.5, 4, 10, 6)
          ..quadraticBezierTo(13.5, 8, 17, 6);
        canvas.drawPath(wave1, p);
        final wave2 = Path()
          ..moveTo(3, 10)
          ..quadraticBezierTo(6.5, 8, 10, 10)
          ..quadraticBezierTo(13.5, 12, 17, 10);
        canvas.drawPath(wave2, p);
        final wave3 = Path()
          ..moveTo(3, 14)
          ..quadraticBezierTo(6.5, 12, 10, 14)
          ..quadraticBezierTo(13.5, 16, 17, 14);
        canvas.drawPath(wave3, p);
        break;
      case NavKey.jtasks:
        // check-square — 原“任务”图标
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(3, 3, w - 6, h - 6),
          const Radius.circular(3),
        );
        canvas.drawRRect(rrect, p);
        final path = Path()
          ..moveTo(7, 10.5)
          ..lineTo(9.5, 13)
          ..lineTo(14, 8);
        canvas.drawPath(path, p);
        break;
      case NavKey.shop:
        // shopping bag
        final bag = Path()
          ..moveTo(4, 6)
          ..lineTo(4, 17)
          ..quadraticBezierTo(4, 18.5, 5.5, 18.5)
          ..lineTo(14.5, 18.5)
          ..quadraticBezierTo(16, 18.5, 16, 17)
          ..lineTo(16, 6)
          ..close();
        canvas.drawPath(bag, p);
        // handle
        final handle = Path()
          ..moveTo(7, 6)
          ..quadraticBezierTo(7, 2.5, 10, 2.5)
          ..quadraticBezierTo(13, 2.5, 13, 6);
        canvas.drawPath(handle, p);
        break;
      case NavKey.history:
        // bar-chart-3
        canvas.drawLine(Offset(4, h - 5), Offset(4, h - 10), p);
        canvas.drawLine(Offset(w / 2, h - 5), Offset(w / 2, h - 13), p);
        canvas.drawLine(Offset(w - 4, h - 5), Offset(w - 4, h - 16), p);
        // baseline
        final base = Paint()
          ..color = color
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(3, h - 4), Offset(w - 3, h - 4), base);
        break;
      case NavKey.profile:
        // user
        canvas.drawCircle(Offset(w / 2, 7.5), 3.2, p);
        final path = Path()
          ..moveTo(w / 2 - 5.5, 17.5)
          ..quadraticBezierTo(w / 2, 13.5, w / 2 + 5.5, 17.5);
        canvas.drawPath(path, p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _NavIcon old) => old.color != color;
}
