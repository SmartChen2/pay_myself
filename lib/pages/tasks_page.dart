import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../state/app_state_scope.dart';
import '../state/app_state.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../i18n/strings.dart';
import '../widgets/status_bar.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_edit_sheet.dart' show showTaskEditSheet;
import '../widgets/task_card.dart';
import '../widgets/duration_sheet.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final p = AppPalette.of(context);
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
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                children: [
                  _Header(p: p),
                  const SizedBox(height: 16),
                  SummaryCard(
                    todayEarnings: state.todayEarnings,
                    focusMinutes: state.todayFocusMinutes,
                    dailyGoalYuan: state.dailyGoalYuan,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t('pmode.section'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: p.mutedForeground,
                        ),
                      ),
                      _AddButton(p: p, onTap: () => _addTask(context, state)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final task in state.tasks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCard(
                        task: task,
                        onTap: () => _pickDuration(context, task),
                        onEdit: () => _editTask(context, state, task),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDuration(BuildContext context, Task task) async {
    final state = AppStateScope.of(context);
    final mins = await showDurationSheet(
      context,
      task: task,
      options: state.focusDurations,
    );
    if (mins == null || !context.mounted) return;
    Navigator.of(context).pushNamed('/focus', arguments: {
      'taskId': task.id,
      'duration': mins,
    });
  }

  void _addTask(BuildContext context, AppState state) async {
    final res = await showTaskEditSheet(context);
    if (res == null || res.delete || res.name == null) return;
    state.addTask(res.name!, res.ratePerHour);
  }

  void _editTask(BuildContext context, AppState state, Task task) async {
    final res = await showTaskEditSheet(context, task: task);
    if (res == null) return;
    if (res.delete) {
      state.removeTask(task.id);
      return;
    }
    state.updateTask(
      task.id,
      name: res.name,
      ratePerHour: res.ratePerHour,
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
            child: Builder(builder: (ctx) => Text(
              ctx.t('pmode.title'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: p.foreground,
                height: 1.15,
              ),
            )),
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
