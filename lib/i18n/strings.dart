import 'package:flutter/widgets.dart';
import '../state/app_state_scope.dart';

/// 轻量级国际化：用 key 查表，{0}/{1}... 为占位符。
/// zh / en 两套字符串。auto 模式跟随系统。
class L10n {
  final String lang; // 'zh' 或 'en'
  const L10n(this.lang);

  bool get isEn => lang == 'en';

  String t(String key, [List<String>? args]) {
    final map = isEn ? _en : _zh;
    var s = map[key] ?? _zh[key] ?? key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        s = s.replaceAll('{$i}', args[i]);
      }
    }
    return s;
  }

  static const _zh = <String, String>{
    // === App ===
    'app.title': 'PayMe 专注',

    // === 底部导航 ===
    'nav.pmode': '专注',
    'nav.jmode': '待办',
    'nav.shop': '商店',
    'nav.history': '记录',
    'nav.profile': '我的',

    // === 专注页 ===
    'pmode.title': '专注',
    'pmode.section': '专注任务',

    // === 待办页 ===
    'jmode.title': '待办',
    'jmode.section': '待办',
    'jmode.empty.title': '还没有待办任务',
    'jmode.empty.hint': '点击右上角添加',

    // === 汇总卡 ===
    'summary.earned': '今日已赚取 {0}',
    'summary.goal': '目标 {0} · 今日专注 {1}',
    'summary.percent': '{0}%',

    // === 商店页 ===
    'shop.title': '商店',
    'shop.subtitle': '用专注赚的金币，奖励自己',
    'shop.available': '可用金币',
    'shop.purchased.n': '已兑换 {0} 件',
    'shop.rewards': '奖励商品',
    'shop.items.n': '{0} 件',
    'shop.recent': '最近兑换',
    'shop.redeem': '兑换',
    'shop.redeem.title': '兑换 {0}',
    'shop.redeem.msg': '将花费 {0} 金币兑换「{1}」？',
    'shop.success': '兑换成功！享受你的 {0} {1}',
    'shop.insufficient': '金币不足，再专注一会儿吧',
    'shop.owned': '已拥有',
    'shop.need.more': '不足',

    // === 内置默认商品(双语) ===
    'shop.default.food.name': '一顿美食',
    'shop.default.food.desc': '好好吃一顿',
    'shop.default.coffee.name': '一杯咖啡',
    'shop.default.coffee.desc': '犒劳片刻的香气',
    'shop.default.game.name': '游戏一小时',
    'shop.default.game.desc': '痛快玩一场',

    // === 记录页 ===
    'history.title': '记录',
    'history.range.week': '周',
    'history.range.month': '月',
    'history.range.year': '年',
    'history.empty.title': '本周期还没有专注记录',
    'history.empty.hint': '切到上个周期看看，或开始一次新的专注',
    'history.earnings': '周期收益',
    'history.count': '专注次数',
    'history.duration': '专注时长',
    'history.sessions.n': '{0} 次',
    'history.task.tag': '任务',

    // === 我的页 ===
    'profile.title': '我的',
    'profile.total': '累计 {0}',
    'profile.total.focus': '累计专注',
    'profile.available': '可用金币',
    'profile.section.prefs': '偏好',
    'profile.section.about': '关于',
    'profile.skin': '显示模式',
    'profile.daily.goal': '每日目标',
    'profile.rain.density': '金币雨密度',
    'profile.rain.style': '雨样式',
    'profile.language': '语言',
    'profile.sound': '音效',
    'profile.focus.duration': '专注时长',
    'profile.focus.duration.hint': '点击编辑默认专注时长',
    'profile.focus.duration.title': '编辑专注时长',
    'profile.focus.duration.add': '添加时长',
    'profile.focus.duration.empty': '至少保留一个时长',
    'profile.focus.duration.invalid': '请输入大于 0 的分钟数',
    'profile.version': '版本',
    'profile.feedback': '反馈',
    'profile.nickname.title': '设置昵称',
    'profile.nickname.hint': '例如：专注达人',
    'profile.nickname.default': '我',
    'profile.goal.title': '每日赚钱目标',
    'profile.goal.hint': '例如：50',
    'profile.goal.invalid': '请输入大于 0 的金额',
    'profile.rain.density.unit': '{0} 枚',
    'profile.rain.density.hint': '数量越多越密集，可能影响性能',
    'profile.avatar.fail.path': '无法获取图片路径，请重试',
    'profile.avatar.fail.save': '保存头像失败，请重试',
    'profile.feedback.copied': '反馈邮箱已复制：{0}',

    // === 内置默认任务(双语) ===
    'task.default.relax.name': '放松工作',
    'task.default.reading.name': '深度阅读',
    'task.default.sport.name': '运动',
    'task.default.cleanup.name': '整理房间',
    'jtask.default.report.name': '写日报',
    'jtask.default.email.name': '回复邮件',
    'jtask.default.desk.name': '整理桌面',

    // === Skin labels ===
    'skin.light': '白色模式',
    'skin.dark': '深色模式',
    'skin.eyecare': '护眼模式',

    // === Rain style labels ===
    'rain.coin': '金币雨',
    'rain.banknote': '钞票雨',

    // === Language labels ===
    'lang.auto': '跟随系统',
    'lang.zh': '中文',
    'lang.en': 'English',

    // === Focus page ===
    'focus.default.name': '专注',
    'focus.paused': '已暂停 · {0}',
    'focus.resume': '继续',
    'focus.pause': '暂停',
    'focus.end': '结束专注',

    // === 时长选择 ===
    'duration.title': '选择专注时长',
    'duration.estimate': '本次预计收益',
    'duration.start': '开始专注',
    'duration.cancel': '取消',
    'duration.recommend': '推荐',
    'duration.hour': '{0}小时',
    'duration.minute': '{0}分钟',
    'duration.hour.half': '1.5小时',

    // === 任务编辑 ===
    'task.edit.new': '新建任务',
    'task.edit.edit': '编辑任务',
    'task.edit.name': '任务名称',
    'task.edit.name.hint': '例如：深度阅读',
    'task.edit.rate': '单价（每小时）',
    'task.edit.rate.hint': '例如：30',
    'task.edit.rate.suffix': '/小时',
    'task.edit.save': '保存',
    'task.edit.add': '添加',
    'task.edit.delete.title': '删除任务',
    'task.edit.delete.msg': '确定删除「{0}」吗？',
    'task.edit.delete.btn': '删除任务',
    'task.edit.cancel': '取消',
    'task.edit.delete.confirm': '删除',
    'task.edit.invalid': '请填写任务名称和单价',

    // === J任务编辑 ===
    'jtask.edit.new': '新建任务',
    'jtask.edit.edit': '编辑任务',
    'jtask.edit.name': '任务名称',
    'jtask.edit.name.hint': '例如：写日报',
    'jtask.edit.coins': '完成可得代币',
    'jtask.edit.coins.suffix': ' / 完成',
    'jtask.edit.coins.hint': '例如：10',
    'jtask.edit.save': '保存',
    'jtask.edit.add': '添加',
    'jtask.edit.delete.title': '删除任务',
    'jtask.edit.delete.msg': '确定删除「{0}」吗？',
    'jtask.edit.delete.btn': '删除任务',
    'jtask.edit.cancel': '取消',
    'jtask.edit.delete.confirm': '删除',
    'jtask.edit.invalid': '请填写任务名称和代币',

    // === 商店编辑 ===
    'shop.edit.new': '新建奖励商品',
    'shop.edit.edit': '编辑奖励商品',
    'shop.edit.icon': '图标',
    'shop.edit.name': '名称',
    'shop.edit.name.hint': '例如：一杯咖啡',
    'shop.edit.desc': '描述',
    'shop.edit.desc.hint': '例如：犒劳片刻的香气',
    'shop.edit.desc.default': '奖励自己',
    'shop.edit.price': '价格(代币)',
    'shop.edit.price.hint': '例如：15',
    'shop.edit.save': '保存',
    'shop.edit.add': '添加',
    'shop.edit.delete.title': '删除商品',
    'shop.edit.delete.msg': '确定删除「{0}」吗？已有兑换记录不受影响。',
    'shop.edit.delete.btn': '删除商品',
    'shop.edit.cancel': '取消',
    'shop.edit.delete.confirm': '删除',
    'shop.edit.invalid': '请填写商品名称和价格',
  };

  static const _en = <String, String>{
    // === App ===
    'app.title': 'PayMe Focus',

    // === bottom nav ===
    'nav.pmode': 'Focus',
    'nav.jmode': 'Todo',
    'nav.shop': 'Shop',
    'nav.history': 'History',
    'nav.profile': 'Profile',

    // === P-mode page ===
    'pmode.title': 'Focus',
    'pmode.section': 'Focus Tasks',

    // === J-mode page ===
    'jmode.title': 'Todo',
    'jmode.section': 'Todo',
    'jmode.empty.title': 'No tasks yet',
    'jmode.empty.hint': 'Tap + to add',

    // === summary card ===
    'summary.earned': 'Earned today: {0}',
    'summary.goal': 'Goal {0} · Focused today {1}',
    'summary.percent': '{0}%',

    // === shop page ===
    'shop.title': 'Shop',
    'shop.subtitle': 'Reward yourself with focus-earned coins',
    'shop.available': 'Available',
    'shop.purchased.n': 'Purchased {0} items',
    'shop.rewards': 'Rewards',
    'shop.items.n': '{0} items',
    'shop.recent': 'Recent',
    'shop.redeem': 'Redeem',
    'shop.redeem.title': 'Redeem {0}',
    'shop.redeem.msg': 'Spend {0} coins to redeem "{1}"?',
    'shop.success': 'Redeemed! Enjoy your {0} {1}',
    'shop.insufficient': 'Not enough coins. Focus a bit more.',
    'shop.owned': 'Owned',
    'shop.need.more': 'Need more',

    // === built-in default rewards (bilingual) ===
    'shop.default.food.name': 'A nice meal',
    'shop.default.food.desc': 'Treat yourself to a good meal',
    'shop.default.coffee.name': 'A cup of coffee',
    'shop.default.coffee.desc': 'A moment of aroma',
    'shop.default.game.name': '1 hour of gaming',
    'shop.default.game.desc': "Play to your heart's content",

    // === history page ===
    'history.title': 'History',
    'history.range.week': 'W',
    'history.range.month': 'M',
    'history.range.year': 'Y',
    'history.empty.title': 'No focus records this period',
    'history.empty.hint': 'Try the previous period, or start a new focus session',
    'history.earnings': 'Period earnings',
    'history.count': 'Sessions',
    'history.duration': 'Focus time',
    'history.sessions.n': '{0} sessions',
    'history.task.tag': 'Task',

    // === profile page ===
    'profile.title': 'Profile',
    'profile.total': 'Total {0}',
    'profile.total.focus': 'Total focus',
    'profile.available': 'Available',
    'profile.section.prefs': 'Preferences',
    'profile.section.about': 'About',
    'profile.skin': 'Theme',
    'profile.daily.goal': 'Daily goal',
    'profile.rain.density': 'Rain density',
    'profile.rain.style': 'Rain style',
    'profile.language': 'Language',
    'profile.sound': 'Sound',
    'profile.focus.duration': 'Focus duration',
    'profile.focus.duration.hint': 'Tap to edit default focus durations',
    'profile.focus.duration.title': 'Edit focus durations',
    'profile.focus.duration.add': 'Add duration',
    'profile.focus.duration.empty': 'Keep at least one duration',
    'profile.focus.duration.invalid': 'Please enter minutes greater than 0',
    'profile.version': 'Version',
    'profile.feedback': 'Feedback',
    'profile.nickname.title': 'Set nickname',
    'profile.nickname.hint': 'e.g., Focus Master',
    'profile.nickname.default': 'Me',
    'profile.goal.title': 'Daily earnings goal',
    'profile.goal.hint': 'e.g., 50',
    'profile.goal.invalid': 'Please enter an amount greater than 0',
    'profile.rain.density.unit': '{0} coins',
    'profile.rain.density.hint': 'More coins = denser, may impact performance',
    'profile.avatar.fail.path': 'Cannot get image path, please retry',
    'profile.avatar.fail.save': 'Failed to save avatar, please retry',
    'profile.feedback.copied': 'Feedback email copied: {0}',

    // === built-in default tasks (bilingual) ===
    'task.default.relax.name': 'Relaxing work',
    'task.default.reading.name': 'Deep reading',
    'task.default.sport.name': 'Exercise',
    'task.default.cleanup.name': 'Tidy up',
    'jtask.default.report.name': 'Write daily report',
    'jtask.default.email.name': 'Reply emails',
    'jtask.default.desk.name': 'Tidy desk',

    // === Skin labels ===
    'skin.light': 'Light',
    'skin.dark': 'Dark',
    'skin.eyecare': 'Eye-care',

    // === Rain style labels ===
    'rain.coin': 'Coins',
    'rain.banknote': 'Bills',

    // === Language labels ===
    'lang.auto': 'Follow system',
    'lang.zh': '中文',
    'lang.en': 'English',

    // === Focus page ===
    'focus.default.name': 'Focus',
    'focus.paused': 'Paused · {0}',
    'focus.resume': 'Resume',
    'focus.pause': 'Pause',
    'focus.end': 'End Focus',

    // === Duration sheet ===
    'duration.title': 'Choose focus duration',
    'duration.estimate': 'Estimated earnings',
    'duration.start': 'Start focus',
    'duration.cancel': 'Cancel',
    'duration.recommend': 'Recommended',
    'duration.hour': '{0}h',
    'duration.minute': '{0}m',
    'duration.hour.half': '1.5h',

    // === Task edit ===
    'task.edit.new': 'New task',
    'task.edit.edit': 'Edit task',
    'task.edit.name': 'Name',
    'task.edit.name.hint': 'e.g., Deep reading',
    'task.edit.rate': 'Hourly rate',
    'task.edit.rate.hint': 'e.g., 30',
    'task.edit.rate.suffix': '/hr',
    'task.edit.save': 'Save',
    'task.edit.add': 'Add',
    'task.edit.delete.title': 'Delete task',
    'task.edit.delete.msg': 'Delete "{0}"?',
    'task.edit.delete.btn': 'Delete task',
    'task.edit.cancel': 'Cancel',
    'task.edit.delete.confirm': 'Delete',
    'task.edit.invalid': 'Please enter name and rate',

    // === J-task edit ===
    'jtask.edit.new': 'New task',
    'jtask.edit.edit': 'Edit task',
    'jtask.edit.name': 'Name',
    'jtask.edit.name.hint': 'e.g., Write daily report',
    'jtask.edit.coins': 'Reward',
    'jtask.edit.coins.suffix': ' / done',
    'jtask.edit.coins.hint': 'e.g., 10',
    'jtask.edit.save': 'Save',
    'jtask.edit.add': 'Add',
    'jtask.edit.delete.title': 'Delete task',
    'jtask.edit.delete.msg': 'Delete "{0}"?',
    'jtask.edit.delete.btn': 'Delete task',
    'jtask.edit.cancel': 'Cancel',
    'jtask.edit.delete.confirm': 'Delete',
    'jtask.edit.invalid': 'Please enter name and reward',

    // === Shop edit ===
    'shop.edit.new': 'New reward',
    'shop.edit.edit': 'Edit reward',
    'shop.edit.icon': 'Icon',
    'shop.edit.name': 'Name',
    'shop.edit.name.hint': 'e.g., A cup of coffee',
    'shop.edit.desc': 'Description',
    'shop.edit.desc.hint': 'e.g., A moment of aroma',
    'shop.edit.desc.default': 'Reward yourself',
    'shop.edit.price': 'Price (coins)',
    'shop.edit.price.hint': 'e.g., 15',
    'shop.edit.save': 'Save',
    'shop.edit.add': 'Add',
    'shop.edit.delete.title': 'Delete reward',
    'shop.edit.delete.msg': 'Delete "{0}"? Existing purchases are not affected.',
    'shop.edit.delete.btn': 'Delete reward',
    'shop.edit.cancel': 'Cancel',
    'shop.edit.delete.confirm': 'Delete',
    'shop.edit.invalid': 'Please enter name and price',
  };
}

/// BuildContext 扩展：通过 AppState 当前 locale 获取翻译。
extension L10nContext on BuildContext {
  String t(String key, [List<String>? args]) {
    final state = AppStateScope.of(this, listen: true);
    return L10n(state.effectiveLanguageCode).t(key, args);
  }
}
