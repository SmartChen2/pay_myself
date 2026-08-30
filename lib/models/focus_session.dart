import 'package:flutter/foundation.dart';

@immutable
class FocusSession {
  final String id;
  final String taskName;
  final int durationMinutes;
  final double reward;
  final DateTime completedAt;

  const FocusSession({
    required this.id,
    required this.taskName,
    required this.durationMinutes,
    required this.reward,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskName': taskName,
        'durationMinutes': durationMinutes,
        'reward': reward,
        'completedAt': completedAt.toIso8601String(),
      };

  factory FocusSession.fromJson(Map<String, dynamic> j) => FocusSession(
        id: j['id'] as String? ?? '',
        taskName: j['taskName'] as String? ?? '',
        durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
        reward: (j['reward'] as num?)?.toDouble() ?? 0,
        completedAt: j['completedAt'] != null
            ? DateTime.tryParse(j['completedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// 三种显示模式：白色 / 深色 / 护眼
enum Skin { light, dark, eyecare }

/// 雨样式：金币雨 / 钞票雨
enum RainStyle { coin, banknote }
