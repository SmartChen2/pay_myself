import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../models/task.dart';
import '../models/jtask.dart';
import '../i18n/strings.dart';
import '../utils/format.dart';

/// 新建 / 编辑任务弹窗
/// [initialName] 用于编辑已有任务时显示 i18n 解析后的名称。
Future<TaskEdit?> showTaskEditSheet(
  BuildContext context, {
  Task? task,
}) {
  final initialName = task != null && task.nameKey != null
      ? context.t(task.nameKey!)
      : task?.name ?? '';
  return showModalBottomSheet<TaskEdit>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    enableDrag: true,
    builder: (_) => _TaskEditSheet(task: task, initialName: initialName),
  );
}

class TaskEdit {
  /// null 表示名称未修改(编辑已有任务且名称未改),用于保留 i18n key。
  final String? name;
  final double ratePerHour;
  final bool delete;
  TaskEdit({
    this.name,
    required this.ratePerHour,
    this.delete = false,
  });
}

/// 新建 / 编辑 J人模式任务弹窗
Future<JTaskEdit?> showJTaskEditSheet(
  BuildContext context, {
  JTask? task,
}) {
  final initialName = task != null && task.nameKey != null
      ? context.t(task.nameKey!)
      : task?.name ?? '';
  return showModalBottomSheet<JTaskEdit>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    enableDrag: true,
    builder: (_) => _JTaskEditSheet(task: task, initialName: initialName),
  );
}

class JTaskEdit {
  /// null 表示名称未修改,用于保留 i18n key。
  final String? name;
  final double coins;
  final bool delete;
  JTaskEdit({
    this.name,
    required this.coins,
    this.delete = false,
  });
}

class _TaskEditSheet extends StatefulWidget {
  final Task? task;
  final String initialName;
  const _TaskEditSheet({this.task, required this.initialName});

  @override
  State<_TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<_TaskEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _rate;
  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _rate = TextEditingController(
      text: widget.task == null ? '' : widget.task!.ratePerHour.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _submit({bool delete = false}) {
    final name = _name.text.trim();
    final rate = double.tryParse(_rate.text.trim()) ?? 0;
    if (name.isEmpty || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('task.edit.invalid'))),
      );
      return;
    }
    // 编辑已有任务且名称未改时传 null,保留 i18n key。
    final nameUnchanged = _isEdit && name == widget.initialName;
    Navigator.of(context).pop(TaskEdit(
      name: nameUnchanged ? null : name,
      ratePerHour: rate,
      delete: delete,
    ));
  }

  TextStyle _labelStyle(AppPalette p) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: p.mutedForeground,
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final padBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: p.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                _isEdit ? context.t('task.edit.edit') : context.t('task.edit.new'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: p.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(context.t('task.edit.name'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: p.foreground),
                decoration: InputDecoration(
                  hintText: context.t('task.edit.name.hint'),
                  hintStyle: TextStyle(color: p.mutedForeground),
                  filled: true,
                  fillColor: p.input,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              Text(context.t('task.edit.rate'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: p.foreground),
                decoration: InputDecoration(
                  prefixText: Format.currencySymbol,
                  suffixText: context.t('task.edit.rate.suffix'),
                  filled: true,
                  fillColor: p.input,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  hintText: context.t('task.edit.rate.hint'),
                  hintStyle: TextStyle(color: p.mutedForeground),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _submit(),
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
                  ),
                ),
                child: Text(_isEdit ? context.t('task.edit.save') : context.t('task.edit.add')),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: p.card,
                        title: Text(context.t('task.edit.delete.title'), style: TextStyle(color: p.foreground)),
                        content: Text(
                          context.t('task.edit.delete.msg', [widget.initialName]),
                          style: TextStyle(color: p.mutedForeground),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(context.t('task.edit.cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppTokens.error),
                            child: Text(context.t('task.edit.delete.confirm')),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) _submit(delete: true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTokens.error,
                  ),
                  child: Text(context.t('task.edit.delete.btn')),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: p.mutedForeground,
                ),
                child: Text(context.t('task.edit.cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JTaskEditSheet extends StatefulWidget {
  final JTask? task;
  final String initialName;
  const _JTaskEditSheet({this.task, required this.initialName});

  @override
  State<_JTaskEditSheet> createState() => _JTaskEditSheetState();
}

class _JTaskEditSheetState extends State<_JTaskEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _coins;
  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _coins = TextEditingController(
      text: widget.task == null ? '' : widget.task!.coins.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _coins.dispose();
    super.dispose();
  }

  void _submit({bool delete = false}) {
    final name = _name.text.trim();
    final coins = double.tryParse(_coins.text.trim()) ?? 0;
    if (name.isEmpty || coins <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('jtask.edit.invalid'))),
      );
      return;
    }
    // 编辑已有任务且名称未改时传 null,保留 i18n key。
    final nameUnchanged = _isEdit && name == widget.initialName;
    Navigator.of(context).pop(JTaskEdit(
      name: nameUnchanged ? null : name,
      coins: coins,
      delete: delete,
    ));
  }

  TextStyle _labelStyle(AppPalette p) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: p.mutedForeground,
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final padBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: p.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                _isEdit ? context.t('jtask.edit.edit') : context.t('jtask.edit.new'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: p.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(context.t('jtask.edit.name'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: p.foreground),
                decoration: InputDecoration(
                  hintText: context.t('jtask.edit.name.hint'),
                  hintStyle: TextStyle(color: p.mutedForeground),
                  filled: true,
                  fillColor: p.input,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              Text(context.t('jtask.edit.coins'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _coins,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: p.foreground),
                decoration: InputDecoration(
                  prefixText: Format.currencySymbol,
                  suffixText: context.t('jtask.edit.coins.suffix'),
                  filled: true,
                  fillColor: p.input,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  hintText: context.t('jtask.edit.coins.hint'),
                  hintStyle: TextStyle(color: p.mutedForeground),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _submit(),
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
                  ),
                ),
                child: Text(_isEdit ? context.t('jtask.edit.save') : context.t('jtask.edit.add')),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: p.card,
                        title: Text(context.t('jtask.edit.delete.title'), style: TextStyle(color: p.foreground)),
                        content: Text(
                          context.t('jtask.edit.delete.msg', [widget.initialName]),
                          style: TextStyle(color: p.mutedForeground),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(context.t('jtask.edit.cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppTokens.error),
                            child: Text(context.t('jtask.edit.delete.confirm')),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) _submit(delete: true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTokens.error,
                  ),
                  child: Text(context.t('jtask.edit.delete.btn')),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: p.mutedForeground,
                ),
                child: Text(context.t('jtask.edit.cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
