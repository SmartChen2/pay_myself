import 'package:flutter/foundation.dart';

/// 待办模式任务 — 完成即获得固定代币（¥）。
@immutable
class JTask {
  final String id;
  final String name;
  final double coins; // 完成可获得的代币金额（¥）
  /// 可选 i18n key:非空时显示用 context.t(nameKey),用于内置默认任务双语。
  /// 用户编辑后会清空,改用 name 文本。
  final String? nameKey;

  const JTask({
    required this.id,
    required this.name,
    required this.coins,
    this.nameKey,
  });

  String get coinLabel => coins % 1 == 0
      ? coins.toStringAsFixed(0)
      : coins.toStringAsFixed(1);

  JTask copyWith({String? name, double? coins, String? nameKey}) {
    return JTask(
      id: id,
      name: name ?? this.name,
      coins: coins ?? this.coins,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coins': coins,
        if (nameKey != null) 'nameKey': nameKey,
      };

  factory JTask.fromJson(Map<String, dynamic> j) => JTask(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        coins: (j['coins'] as num?)?.toDouble() ?? 0,
        nameKey: j['nameKey'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is JTask && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
