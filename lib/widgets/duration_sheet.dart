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
  required List<int> options,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _DurationSheet(task: task, options: options),
  );
}

class _DurationSheet extends StatefulWidget {
  final Task task;
  final List<int> options;
  const _DurationSheet({required this.task, required this.options});

  @override
  State<_DurationSheet> createState() => _DurationSheetState();
}

class _DurationSheetState extends State<_DurationSheet> {
  /// 默认选中第一档（用户在"我的"页排在最前的时长）。
  late int _selected = widget.options.first;

  List<int> get _options => widget.options;

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
            const SizedBox(height: 20),
            // 竖直列表：4 个选项，依次递增
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final d in _options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DurationRow(
                      duration: d,
                      reward: widget.task.rewardFor(d),
                      selected: d == _selected,
                      onTap: () => setState(() => _selected = d),
                    ),
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

/// 竖直列表中的一行：左侧时长 + 收益，右侧选中标记
class _DurationRow extends StatelessWidget {
  final int duration;
  final double reward;
  final bool selected;
  final VoidCallback onTap;
  const _DurationRow({
    required this.duration,
    required this.reward,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? p.goldSoft : p.card,
          border: Border.all(
            color: selected ? p.gold : p.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          boxShadow: selected ? AppShadows.shadowGold : null,
        ),
        child: Row(
          children: [
            // 时长
            Text(
              _durLabel(context, duration),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: p.foreground,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            // 收益
            Row(
              mainAxisSize: MainAxisSize.min,
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
            const Spacer(),
            // 选中标记
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? p.gold : Colors.transparent,
                border: Border.all(
                  color: selected ? p.gold : p.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 时长标签：40min / 1h / 1.5h / 2h（中英双语，适配任意分钟值）
  String _durLabel(BuildContext c, int d) {
    if (d == 90) return c.t('duration.hour.half');
    if (d % 60 == 0) return c.t('duration.hour', ['${d ~/ 60}']);
    return c.t('duration.minute', ['$d']);
  }
}
