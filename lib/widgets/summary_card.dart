import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../utils/format.dart';
import '../i18n/strings.dart';
import 'icons.dart';

/// 汇总卡:今日已赚取(金额目标 + 进度条)+ 今日专注时间
class SummaryCard extends StatelessWidget {
  final double todayEarnings;
  final int focusMinutes;
  final double dailyGoalYuan;
  const SummaryCard({
    super.key,
    required this.todayEarnings,
    required this.focusMinutes,
    required this.dailyGoalYuan,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final progress = dailyGoalYuan == 0
        ? 0.0
        : (todayEarnings / dailyGoalYuan).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.goldSoft, p.goldSoft.withOpacity(0.5)],
        ),
        border: Border.all(color: p.gold.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [BoxShadow(color: p.goldShadow, blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinIcon(size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.t('summary.earned', [Format.yuan(todayEarnings)]),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: p.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          LayoutBuilder(
            builder: (context, c) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    children: [
                      Container(color: p.gold.withOpacity(0.16)),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [p.goldLight, p.gold],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('summary.goal', [Format.yuan(dailyGoalYuan), Format.minLabel(focusMinutes)]),
                style: TextStyle(
                  fontSize: 11,
                  color: p.mutedForeground,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 11,
                  color: p.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
