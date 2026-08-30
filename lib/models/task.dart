import 'package:flutter/foundation.dart';

@immutable
class Task {
  final String id;
  final String name;
  final double ratePerHour; // ¥/小时
  /// 可选 i18n key:非空时显示用 context.t(nameKey),用于内置默认任务双语。
  /// 用户编辑后会清空,改用 name 文本。
  final String? nameKey;

  const Task({
    required this.id,
    required this.name,
    required this.ratePerHour,
    this.nameKey,
  });

  /// 收益 = 时薪 × 时长
  double rewardFor(int minutes) {
    if (minutes <= 0) return 0;
    return ratePerHour * minutes / 60;
  }

  String get rateLabel =>
      ratePerHour % 1 == 0
          ? ratePerHour.toStringAsFixed(0)
          : ratePerHour.toStringAsFixed(1);

  Task copyWith({String? name, double? ratePerHour, String? nameKey}) {
    return Task(
      id: id,
      name: name ?? this.name,
      ratePerHour: ratePerHour ?? this.ratePerHour,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ratePerHour': ratePerHour,
        if (nameKey != null) 'nameKey': nameKey,
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        ratePerHour: (j['ratePerHour'] as num?)?.toDouble() ?? 0,
        nameKey: j['nameKey'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
