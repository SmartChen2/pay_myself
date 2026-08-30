import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../state/app_state_scope.dart';
import '../utils/format.dart';
import '../models/focus_session.dart';
import '../widgets/status_bar.dart';
import '../widgets/icons.dart';
import '../i18n/strings.dart';

enum _Range { week, month, year }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _Range _range = _Range.week;
  /// 当前周期的锚点:周/月/年都用此日期所在周期
  DateTime _anchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final p = AppPalette.of(context);
    // 周期边界
    final start = _periodStart(_anchor, _range);
    final end = _periodEnd(_anchor, _range);
    final sessions = state.history
        .where((s) =>
            !s.completedAt.isBefore(start) && s.completedAt.isBefore(end))
        .toList();
    // 按完成时间倒序
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final earnings =
        sessions.fold<double>(0, (s, e) => s + e.reward);
    final count = sessions.length;
    final minutes =
        sessions.fold<int>(0, (s, e) => s + e.durationMinutes);

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const IosStatusBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                children: [
                  // 大标题
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 14),
                    child: Text(
                      context.t('history.title'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: p.foreground,
                        height: 1.15,
                      ),
                    ),
                  ),
                  // iOS 风格分段控件
                  _SegmentedControl<_Range>(
                    p: p,
                    values: const [_Range.week, _Range.month, _Range.year],
                    labels: [
                      context.t('history.range.week'),
                      context.t('history.range.month'),
                      context.t('history.range.year'),
                    ],
                    selected: _range,
                    onChanged: (v) => setState(() => _range = v),
                  ),
                  const SizedBox(height: 14),
                  // 周期切换 + 当前周期标签
                  _PeriodNav(
                    p: p,
                    label: _periodLabel(start, _range),
                    onPrev: () => setState(() => _anchor = _shift(_anchor, _range, -1)),
                    onNext: () => setState(() => _anchor = _shift(_anchor, _range, 1)),
                  ),
                  const SizedBox(height: 18),
                  // 汇总卡
                  _SummaryCard(
                    p: p,
                    earnings: earnings,
                    count: count,
                    minutes: minutes,
                  ),
                  const SizedBox(height: 20),
                  // 分组记录
                  if (sessions.isEmpty)
                    _empty(p)
                  else
                    ..._buildGroups(sessions, p, _range),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 周期起始(包含),按周一为周首日
  DateTime _periodStart(DateTime a, _Range r) {
    switch (r) {
      case _Range.week:
        final d = DateTime(a.year, a.month, a.day);
        return d.subtract(Duration(days: d.weekday - 1));
      case _Range.month:
        return DateTime(a.year, a.month, 1);
      case _Range.year:
        return DateTime(a.year, 1, 1);
    }
  }

  /// 周期结束(不含)
  DateTime _periodEnd(DateTime a, _Range r) {
    switch (r) {
      case _Range.week:
        return _periodStart(a, r).add(const Duration(days: 7));
      case _Range.month:
        final s = DateTime(a.year, a.month, 1);
        return DateTime(s.year, s.month + 1, 1);
      case _Range.year:
        return DateTime(a.year + 1, 1, 1);
    }
  }

  /// 前 / 后移一个周期
  DateTime _shift(DateTime a, _Range r, int dir) {
    switch (r) {
      case _Range.week:
        return a.add(Duration(days: 7 * dir));
      case _Range.month:
        return DateTime(a.year, a.month + dir, a.day);
      case _Range.year:
        return DateTime(a.year + dir, a.month, a.day);
    }
  }

  /// 周期展示标签
  String _periodLabel(DateTime start, _Range r) {
    switch (r) {
      case _Range.week:
        return Format.range(start, start.add(const Duration(days: 6)));
      case _Range.month:
        return Format.yearMonth(start);
      case _Range.year:
        return Format.yearOnly(start);
    }
  }

  /// 按日 / 按月 分组,返回每组(groupHeader, sessions)的 widget 列表
  List<Widget> _buildGroups(
      List<FocusSession> sessions, AppPalette p, _Range r) {
    // 分组键
    String keyOf(FocusSession s) {
      switch (r) {
        case _Range.week:
        case _Range.month:
          return '${s.completedAt.year}-${s.completedAt.month}-${s.completedAt.day}';
        case _Range.year:
          return '${s.completedAt.year}-${s.completedAt.month}';
      }
    }

    String labelOf(FocusSession s) {
      switch (r) {
        case _Range.week:
          return Format.dateWithWeek(s.completedAt);
        case _Range.month:
          return '${Format.date(s.completedAt)} ${Format.weekday(s.completedAt)}';
        case _Range.year:
          return Format.yearMonth(s.completedAt);
      }
    }

    // 按键聚合,保持首次出现顺序(sessions 已经是倒序)
    final Map<String, List<FocusSession>> groups = {};
    for (final s in sessions) {
      final k = keyOf(s);
      groups.putIfAbsent(k, () => []).add(s);
    }
    // 组内子汇总
    final widgets = <Widget>[];
    groups.forEach((k, list) {
      final earnings = list.fold<double>(0, (s, e) => s + e.reward);
      final minutes = list.fold<int>(0, (s, e) => s + e.durationMinutes);
      widgets.add(const SizedBox(height: 8));
      widgets.add(_RecordGroup(
        p: p,
        title: labelOf(list.first),
        subtitle: minutes == 0
            ? context.t('history.sessions.n', ['${list.length}'])
            : '${context.t('history.sessions.n', ['${list.length}'])} · ${Format.minLabel(minutes)}',
        total: Format.yuan(earnings),
        sessions: list,
      ));
    });
    return widgets;
  }

  Widget _empty(AppPalette p) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 40, color: p.mutedForeground.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            context.t('history.empty.title'),
            style: TextStyle(color: p.mutedForeground, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('history.empty.hint'),
            style: TextStyle(color: p.mutedForeground, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// iOS 风格分段控件 — 灰底 + 滑动白色指示器
class _SegmentedControl<T> extends StatelessWidget {
  final AppPalette p;
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  const _SegmentedControl({
    required this.p,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final idx = values.indexOf(selected);
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: p.input,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final segW = (c.maxWidth) / values.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: idx * segW,
                top: 0,
                bottom: 0,
                width: segW,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: p.foreground.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(values[i]),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: i == idx
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: i == idx
                                  ? p.foreground
                                  : p.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 周期切换导航行 — 左箭头 / 周期标签 / 右箭头
class _PeriodNav extends StatelessWidget {
  final AppPalette p;
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _PeriodNav({
    required this.p,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = p.mutedForeground;
    return Row(
      children: [
        _navBtn(iconColor, Icons.chevron_left, onPrev),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.foreground,
              ),
            ),
          ),
        ),
        _navBtn(iconColor, Icons.chevron_right, onNext),
      ],
    );
  }

  Widget _navBtn(Color c, IconData ic, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(ic, color: c, size: 22),
      ),
    );
  }
}

/// 汇总卡 — 周期内的收益 / 次数 / 时长
class _SummaryCard extends StatelessWidget {
  final AppPalette p;
  final double earnings;
  final int count;
  final int minutes;
  const _SummaryCard({
    required this.p,
    required this.earnings,
    required this.count,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.goldSoft, p.goldSoft.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: p.gold.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(Format.yuan(earnings), context.t('history.earnings'), gold: true),
          _divider(),
          _stat(context.t('history.sessions.n', ['$count']), context.t('history.count')),
          _divider(),
          _stat(Format.minLabel(minutes), context.t('history.duration')),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, {bool gold = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: gold ? p.gold : p.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: p.mutedForeground),
        ),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 28, color: p.gold.withOpacity(0.2));
}

/// 一组记录 — 圆角容器内:组头 + 用细分割线分隔的多条 session
class _RecordGroup extends StatelessWidget {
  final AppPalette p;
  final String title;
  final String subtitle;
  final String total;
  final List<FocusSession> sessions;
  const _RecordGroup({
    required this.p,
    required this.title,
    required this.subtitle,
    required this.total,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          // 组头
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: p.cardForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  total,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.gold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· $subtitle',
                  style: TextStyle(
                    fontSize: 11,
                    color: p.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: p.border, indent: 16, endIndent: 16),
          // session 行
          for (var i = 0; i < sessions.length; i++) ...[
            _SessionRow(p: p, session: sessions[i]),
            if (i < sessions.length - 1)
              Divider(height: 1, color: p.border, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final AppPalette p;
  final FocusSession session;
  const _SessionRow({required this.p, required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          CoinIcon(size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.taskName,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: p.cardForeground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.durationMinutes == 0
                      ? '${Format.time(session.completedAt)} · ${context.t('history.task.tag')}'
                      : '${Format.time(session.completedAt)} · ${Format.minLabel(session.durationMinutes)}',
                  style: TextStyle(fontSize: 11.5, color: p.mutedForeground),
                ),
              ],
            ),
          ),
          Text(
            Format.yuan(session.reward),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: p.gold,
            ),
          ),
        ],
      ),
    );
  }
}
