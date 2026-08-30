import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../models/task.dart';
import '../i18n/strings.dart';
import '../utils/format.dart';
import 'icons.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
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
                          '${Format.currencySymbol}${task.rateLabel}${context.t('task.edit.rate.suffix')}',
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
              InkWell(
                onTap: onEdit,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: const Size.square(16),
                    painter: _EditPainter(color: p.mutedForeground),
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

class _EditPainter extends CustomPainter {
  final Color color;
  _EditPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final d = size.width;
    // square + pencil (edit icon)
    final path = Path()
      ..moveTo(d * 0.46, d * 0.17)
      ..lineTo(d * 0.17, d * 0.17)
      ..quadraticBezierTo(d * 0.083, d * 0.17, d * 0.083, d * 0.25)
      ..lineTo(d * 0.083, d * 0.83)
      ..quadraticBezierTo(d * 0.083, d * 0.917, d * 0.17, d * 0.917)
      ..lineTo(d * 0.83, d * 0.917)
      ..quadraticBezierTo(d * 0.917, d * 0.917, d * 0.917, d * 0.83)
      ..lineTo(d * 0.917, d * 0.54);
    canvas.drawPath(path, p);
    final pencil = Path()
      ..moveTo(d * 0.77, d * 0.10)
      ..cubicTo(d * 0.82, d * 0.06, d * 0.89, d * 0.06, d * 0.94, d * 0.125)
      ..cubicTo(d * 0.89, d * 0.06, d * 0.94, d * 0.06, d * 0.94, d * 0.125)
      ..lineTo(d * 0.5, d * 0.625)
      ..lineTo(d * 0.375, d * 0.708)
      ..lineTo(d * 0.417, d * 0.583)
      ..close();
    canvas.drawPath(pencil, p);
  }

  @override
  bool shouldRepaint(covariant _EditPainter old) => old.color != color;
}
