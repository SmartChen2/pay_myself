class Format {
  Format._();

  /// 当前生效语言代码，由 AppState 在加载/切换时设置。
  /// 'zh' 或 'en'。影响日期/周几/月份的中英显示。
  static String currentLang = 'zh';

  static bool get _isEn => currentLang == 'en';

  /// 货币符号跟随语言：中文 ¥，英文 $。
  static String get currencySymbol => _isEn ? '\$' : '¥';

  /// 货币符号跟随语言：中文 ¥，英文 $。
  /// 字段名保留 yuan 不变（仅内部命名，不影响用户）。
  static String yuan(double v) =>
      '$currencySymbol${v.toStringAsFixed(2)}';

  /// plain number 3.00
  static String num2(double v) => v.toStringAsFixed(2);

  /// mm:ss
  static String clock(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    final mm = m < 10 ? '0$m' : '$m';
    final ss = s < 10 ? '0$s' : '$s';
    return '$mm:$ss';
  }

  /// zh: 1小时20分 / 20分 ; en: 1h20m / 20m
  static String minLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (_isEn) {
      if (h > 0 && m > 0) return '${h}h${m}m';
      if (h > 0) return '${h}h';
      return '${m}m';
    }
    if (h > 0 && m > 0) return '${h}小时${m}分';
    if (h > 0) return '${h}小时';
    return '${m}分';
  }

  static String _pad2(int v) => v < 10 ? '0$v' : '$v';

  /// zh: 08月25日 ; en: Aug 25
  static String date(DateTime d) => _isEn
      ? '${_monthShortEn(d.month)} ${_pad2(d.day)}'
      : '${_pad2(d.month)}月${_pad2(d.day)}日';

  /// 09:41
  static String time(DateTime d) =>
      '${_pad2(d.hour)}:${_pad2(d.minute)}';

  /// 08.25
  static String monthDay(DateTime d) =>
      '${_pad2(d.month)}.${_pad2(d.day)}';

  /// zh: 周一..周日 ; en: Mon..Sun
  static const _weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static String weekday(DateTime d) {
    final list = _isEn ? _weekdaysEn : _weekdaysZh;
    return list[d.weekday - 1];
  }

  /// zh: 8月 ; en: Aug
  static String monthOnly(DateTime d) =>
      _isEn ? _monthShortEn(d.month) : '${d.month}月';

  /// zh: 8月25日 周一 ; en: Aug 25 Mon
  static String dateWithWeek(DateTime d) =>
      _isEn ? '${_monthShortEn(d.month)} ${_pad2(d.day)} ${weekday(d)}'
            : '${date(d)} ${weekday(d)}';

  /// 周期范围: 08.24 - 08.30 — 双语共用
  static String range(DateTime start, DateTime end) =>
      '${monthDay(start)} - ${monthDay(end)}';

  /// zh: 2026年8月 ; en: Aug 2026
  static String yearMonth(DateTime d) => _isEn
      ? '${_monthShortEn(d.month)} ${d.year}'
      : '${d.year}年${d.month}月';

  /// zh: 2026年 ; en: 2026
  static String yearOnly(DateTime d) =>
      _isEn ? '${d.year}' : '${d.year}年';

  static String _monthShortEn(int m) => switch (m) {
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec',
        _ => '',
      };
}
