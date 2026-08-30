import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../models/task.dart';
import '../i18n/strings.dart';
import '../utils/format.dart';
import 'icons.dart';

/// 选择专注时长 — 底部弹窗（bottom sheet）
/// 返回选中的时长（分钟）；取消返回 null。
Future<int?> showDurationSheet(
  BuildContext context, {
  required Task task,
  int initial = 25,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _DurationSheet(task: task, initial: initial),
  );
}

class _DurationSheet extends StatefulWidget {
  final Task task;
  final int initial;
  const _DurationSheet({required this.task, required this.initial});

  @override
  State<_DurationSheet> createState() => _DurationSheetState();
}

class _DurationSheetState extends State<_DurationSheet> {
  late int _selected = widget.initial;
  // 与设计稿一致:15 / 25 / 45 / 60 分钟,25 分钟为推荐项
  static const _options = [15, 25, 45, 60];
  static const _recommended = 25;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final padBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: AppShadows.shadow2,
      ),
      padding: EdgeInsets.fromLTRB(20, 24, 20, (padBottom + 32).clamp(32, 64)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // grab handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.task.nameKey != null
                  ? context.t(widget.task.nameKey!)
                  : widget.task.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: p.foreground,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.t('duration.title'),
              style: TextStyle(fontSize: 13, color: p.mutedForeground),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                for (final d in _options)
                  _DurationCard(
                    duration: d,
                    reward: widget.task.rewardFor(d),
                    recommended: d == _recommended,
                    selected: d == _selected,
                    onTap: () => setState(() => _selected = d),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.border, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.t('duration.estimate'),
                    style: TextStyle(fontSize: 15, color: p.mutedForeground),
                  ),
                  Row(
                    children: [
                      CoinIcon(size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${Format.currencySymbol}${widget.task.rewardFor(_selected).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: p.gold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: p.gold,
                  foregroundColor: p.foreground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                child: Text(context.t('duration.start')),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                style: TextButton.styleFrom(
                  foregroundColor: p.mutedForeground,
                  textStyle: const TextStyle(fontSize: 15),
                ),
                child: Text(context.t('duration.cancel')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final int duration;
  final double reward;
  final bool recommended;
  final bool selected;
  final VoidCallback onTap;
  const _DurationCard({
    required this.duration,
    required this.reward,
    required this.recommended,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: selected ? p.goldSoft : p.card,
              border: Border.all(
                color: selected ? p.gold : p.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              boxShadow: selected ? AppShadows.shadowGold : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _durLabel(context, duration),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: p.foreground,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CoinIcon(size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${Format.currencySymbol}${reward.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: p.gold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (recommended)
          Positioned(
            top: -9,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: p.gold,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: p.gold.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                context.t('duration.recommend'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: p.foreground,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _durLabel(BuildContext c, int d) {
    if (d >= 60 && d % 60 == 0) {
      return c.t('duration.hour', ['${d ~/ 60}']);
    }
    return c.t('duration.minute', ['$d']);
  }
}
