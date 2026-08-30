import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/task.dart';
import '../models/jtask.dart';
import '../models/focus_session.dart';
import '../models/shop_item.dart';
import '../theme/app_palette.dart';
import '../utils/storage.dart';
import '../utils/format.dart';

class AppState extends ChangeNotifier {
  List<Task> _tasks = [
    const Task(id: 'task-relax', name: '放松工作', ratePerHour: 30, nameKey: 'task.default.relax.name'),
    const Task(id: 'task-reading', name: '深度阅读', ratePerHour: 20, nameKey: 'task.default.reading.name'),
    const Task(id: 'task-sport', name: '运动', ratePerHour: 20, nameKey: 'task.default.sport.name'),
    const Task(id: 'task-cleanup', name: '整理房间', ratePerHour: 10, nameKey: 'task.default.cleanup.name'),
  ];

  List<JTask> _jtasks = [
    const JTask(id: 'jtask-1', name: '写日报', coins: 10, nameKey: 'jtask.default.report.name'),
    const JTask(id: 'jtask-2', name: '回复邮件', coins: 5, nameKey: 'jtask.default.email.name'),
    const JTask(id: 'jtask-3', name: '整理桌面', coins: 8, nameKey: 'jtask.default.desk.name'),
  ];

  List<FocusSession> _history = [];
  List<Purchase> _purchases = [];

  Skin _skin = Skin.light;
  double _dailyGoalYuan = 50;
  bool _soundEnabled = true;
  int _coinRainDensity = 14;
  RainStyle _rainStyle = RainStyle.coin;
  /// 'auto' / 'zh' / 'en'；auto 时跟随系统语言
  String _localeOverride = 'auto';
  int _seq = 100;

  // === 用户资料(本地持久化) ===
  // 空字符串表示未设置,显示时回退到 i18n key 'profile.nickname.default'。
  String _nickname = '';
  String? _avatarPath; // 头像图片本地路径(已复制到应用数据目录)

  // === 商店商品(用户可增删改) ===
  List<ShopItem> _shopItems = [
    const ShopItem(id: 'shop-food', name: '一顿美食', emoji: '🍜', description: '好好吃一顿', price: 60, nameKey: 'shop.default.food.name', descKey: 'shop.default.food.desc'),
    const ShopItem(id: 'shop-coffee', name: '一杯咖啡', emoji: '☕', description: '犒劳片刻的香气', price: 15, nameKey: 'shop.default.coffee.name', descKey: 'shop.default.coffee.desc'),
    const ShopItem(id: 'shop-game', name: '游戏一小时', emoji: '🎮', description: '痛快玩一场', price: 30, nameKey: 'shop.default.game.name', descKey: 'shop.default.game.desc'),
  ];

  AppState() {
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 系统语言变更时刷新（仅 auto 模式生效）
      PlatformDispatcher.instance.onLocaleChanged = () {
        if (_localeOverride == 'auto') {
          Format.currentLang = effectiveLanguageCode;
          notifyListeners();
        }
      };
    });
  }

  /// 从磁盘加载持久化状态。覆盖默认值。
  Future<void> _load() async {
    final j = await Storage.load();
    if (j.isEmpty) {
      // 首次启动：英文系统套用美国物价默认值，否则保留中文默认值。
      if (effectiveLanguageCode == 'en') _applyEnDefaults();
      Format.currentLang = effectiveLanguageCode;
      notifyListeners();
      return;
    }
    final shop = j['shopItems'];
    if (shop is List) {
      _shopItems = shop
          .map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final hist = j['history'];
    if (hist is List) {
      _history = hist
          .map((e) => FocusSession.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final pur = j['purchases'];
    if (pur is List) {
      _purchases = pur
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final tasks = j['tasks'];
    if (tasks is List) {
      _tasks = tasks
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final jtasks = j['jtasks'];
    if (jtasks is List) {
      _jtasks = jtasks
          .map((e) => JTask.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final skin = j['skin'];
    if (skin is String) {
      _skin = Skin.values.firstWhere(
        (s) => s.name == skin,
        orElse: () => Skin.light,
      );
    }
    final goal = j['dailyGoalYuan'];
    if (goal is num) _dailyGoalYuan = goal.toDouble();
    final snd = j['soundEnabled'];
    if (snd is bool) _soundEnabled = snd;
    final dens = j['coinRainDensity'];
    if (dens is int) _coinRainDensity = dens;
    final rs = j['rainStyle'];
    if (rs is String) {
      _rainStyle = RainStyle.values.firstWhere(
        (r) => r.name == rs,
        orElse: () => RainStyle.coin,
      );
    }
    final loc = j['localeOverride'];
    if (loc is String) _localeOverride = loc;
    final seq = j['seq'];
    if (seq is int) _seq = seq;
    final nick = j['nickname'];
    if (nick is String) _nickname = nick;
    final av = j['avatarPath'];
    if (av is String) _avatarPath = av;
    Format.currentLang = effectiveLanguageCode;
    notifyListeners();
  }

  /// 英文系统首次启动时套用美国物价默认值（仅改数值，i18n key 不变）。
  void _applyEnDefaults() {
    _tasks = [
      const Task(id: 'task-relax', name: '放松工作', ratePerHour: 15, nameKey: 'task.default.relax.name'),
      const Task(id: 'task-reading', name: '深度阅读', ratePerHour: 10, nameKey: 'task.default.reading.name'),
      const Task(id: 'task-sport', name: '运动', ratePerHour: 10, nameKey: 'task.default.sport.name'),
      const Task(id: 'task-cleanup', name: '整理房间', ratePerHour: 8, nameKey: 'task.default.cleanup.name'),
    ];
    _shopItems = [
      const ShopItem(id: 'shop-food', name: '一顿美食', emoji: '🍜', description: '好好吃一顿', price: 12, nameKey: 'shop.default.food.name', descKey: 'shop.default.food.desc'),
      const ShopItem(id: 'shop-coffee', name: '一杯咖啡', emoji: '☕', description: '犒劳片刻的香气', price: 5, nameKey: 'shop.default.coffee.name', descKey: 'shop.default.coffee.desc'),
      const ShopItem(id: 'shop-game', name: '游戏一小时', emoji: '🎮', description: '痛快玩一场', price: 6, nameKey: 'shop.default.game.name', descKey: 'shop.default.game.desc'),
    ];
    _dailyGoalYuan = 40;
  }

  /// 把当前状态写入磁盘。
  Future<void> _persist() async {
    await Storage.save({
      'tasks': _tasks.map((e) => e.toJson()).toList(),
      'jtasks': _jtasks.map((e) => e.toJson()).toList(),
      'shopItems': _shopItems.map((e) => e.toJson()).toList(),
      'history': _history.map((e) => e.toJson()).toList(),
      'purchases': _purchases.map((e) => e.toJson()).toList(),
      'skin': _skin.name,
      'dailyGoalYuan': _dailyGoalYuan,
      'soundEnabled': _soundEnabled,
      'coinRainDensity': _coinRainDensity,
      'rainStyle': _rainStyle.name,
      'localeOverride': _localeOverride,
      'seq': _seq,
      'nickname': _nickname,
      'avatarPath': _avatarPath,
    });
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<JTask> get jtasks => List.unmodifiable(_jtasks);
  List<FocusSession> get history => List.unmodifiable(_history);
  List<Purchase> get purchases => List.unmodifiable(_purchases);
  List<ShopItem> get shopItems => List.unmodifiable(_shopItems);
  Skin get skin => _skin;
  AppPalette get palette => AppPalette.forSkin(_skin);
  double get dailyGoalYuan => _dailyGoalYuan;
  bool get soundEnabled => _soundEnabled;
  int get coinRainDensity => _coinRainDensity;
  RainStyle get rainStyle => _rainStyle;
  String get localeOverride => _localeOverride;
  String get nickname => _nickname;
  String? get avatarPath => _avatarPath;

  /// 实际生效的语言代码：'zh' 或 'en'。auto 时跟随系统。
  String get effectiveLanguageCode {
    if (_localeOverride == 'zh') return 'zh';
    if (_localeOverride == 'en') return 'en';
    final sysLang = PlatformDispatcher.instance.locale.languageCode;
    return sysLang == 'zh' ? 'zh' : 'en';
  }

  Locale get effectiveLocale => Locale(effectiveLanguageCode);

  // === 代币 / 收益 ===
  double get totalEarned =>
      _history.fold(0.0, (s, e) => s + e.reward);

  double get totalSpent =>
      _purchases.fold(0.0, (s, e) => s + e.price);

  double get balance => totalEarned - totalSpent;

  double get todayEarnings =>
      todaySessions.fold(0.0, (s, e) => s + e.reward);

  int get todayFocusCount => todaySessions.length;

  int get todayFocusMinutes =>
      todaySessions.fold(0, (s, e) => s + e.durationMinutes);

  int get purchaseCount => _purchases.length;

  bool ownsItem(String shopId) =>
      _purchases.any((p) => p.id == 'purchase-$shopId');

  List<FocusSession> get todaySessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _history.where((s) => s.completedAt.isAfter(today)).toList();
  }

  // === Actions ===
  void setSkin(Skin s) {
    if (_skin == s) return;
    _skin = s;
    notifyListeners();
    _persist();
  }

  void setDailyGoalYuan(double v) {
    if (v <= 0 || v == _dailyGoalYuan) return;
    _dailyGoalYuan = v;
    notifyListeners();
    _persist();
  }

  void setSoundEnabled(bool v) {
    if (v == _soundEnabled) return;
    _soundEnabled = v;
    notifyListeners();
    _persist();
  }

  /// 调整金币雨密度(金币数量),范围 2..40
  void setCoinRainDensity(int v) {
    final clamped = v.clamp(2, 40);
    if (clamped == _coinRainDensity) return;
    _coinRainDensity = clamped;
    notifyListeners();
    _persist();
  }

  /// 切换雨样式（金币 / 钞票）
  void setRainStyle(RainStyle s) {
    if (s == _rainStyle) return;
    _rainStyle = s;
    notifyListeners();
    _persist();
  }

  /// 切换语言：'auto' / 'zh' / 'en'
  void setLocaleOverride(String v) {
    if (v != 'auto' && v != 'zh' && v != 'en') return;
    if (v == _localeOverride) return;
    _localeOverride = v;
    Format.currentLang = effectiveLanguageCode;
    notifyListeners();
    _persist();
  }

  /// 设置昵称(去首尾空白后非空才更新)
  void setNickname(String v) {
    final t = v.trim();
    if (t.isEmpty || t == _nickname) return;
    _nickname = t;
    notifyListeners();
    _persist();
  }

  /// 设置头像本地路径(null 表示清除头像)
  void setAvatarPath(String? path) {
    if (path == _avatarPath) return;
    _avatarPath = path;
    notifyListeners();
    _persist();
  }

  Task? findTask(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  ShopItem? findShopItem(String id) {
    for (final it in _shopItems) {
      if (it.id == id) return it;
    }
    return null;
  }

  void addTask(String name, double ratePerHour) {
    final id = 'task-${++_seq}';
    _tasks.insert(0, Task(id: id, name: name, ratePerHour: ratePerHour));
    notifyListeners();
    _persist();
  }

  void updateTask(String id, {String? name, double? ratePerHour}) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final old = _tasks[i];
    // 用户改了名称就清掉 nameKey,改用用户输入的文本显示。
    _tasks[i] = Task(
      id: old.id,
      name: name ?? old.name,
      ratePerHour: ratePerHour ?? old.ratePerHour,
      nameKey: name != null ? null : old.nameKey,
    );
    notifyListeners();
    _persist();
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _persist();
  }

  // === J人模式 任务（固定代币、完成即入账） ===
  JTask? findJTask(String id) {
    for (final t in _jtasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  void addJTask(String name, double coins) {
    final id = 'jtask-${++_seq}';
    _jtasks.insert(0, JTask(id: id, name: name, coins: coins));
    notifyListeners();
    _persist();
  }

  void updateJTask(String id, {String? name, double? coins}) {
    final i = _jtasks.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final old = _jtasks[i];
    // 用户改了名称就清掉 nameKey,改用用户输入的文本显示。
    _jtasks[i] = JTask(
      id: old.id,
      name: name ?? old.name,
      coins: coins ?? old.coins,
      nameKey: name != null ? null : old.nameKey,
    );
    notifyListeners();
    _persist();
  }

  void removeJTask(String id) {
    _jtasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _persist();
  }

  /// 完成 J人模式任务：把代币金额作为收益记入历史，并从清单移除。
  /// [displayName] 为任务在当前语言下的可读名(由调用方解析 i18n key),
  /// 未提供时回退到 task.name。
  void completeJTask(JTask task, {String? displayName}) {
    _history.insert(0, FocusSession(
      id: 'session-${++_seq}',
      taskName: displayName ?? task.name,
      durationMinutes: 0,
      reward: task.coins,
      completedAt: DateTime.now(),
    ));
    _jtasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
    _persist();
  }

  void completeSession({
    required Task task,
    required int durationMinutes,
    required double reward,
    String? displayName,
  }) {
    _history.insert(0, FocusSession(
      id: 'session-${++_seq}',
      taskName: displayName ?? task.name,
      durationMinutes: durationMinutes,
      reward: reward,
      completedAt: DateTime.now(),
    ));
    notifyListeners();
    _persist();
  }

  /// 购买商品。余额不足返回 false。
  bool purchase(ShopItem item) {
    if (balance < item.price) return false;
    _purchases.insert(0, Purchase(
      id: 'purchase-${item.id}',
      itemName: item.name,
      emoji: item.emoji,
      price: item.price,
      at: DateTime.now(),
    ));
    notifyListeners();
    _persist();
    return true;
  }

  // === 奖励商品增删改 ===
  void addShopItem({
    required String name,
    required String emoji,
    required String description,
    required double price,
  }) {
    _shopItems.insert(0, ShopItem(
      id: 'shop-${++_seq}',
      name: name,
      emoji: emoji,
      description: description,
      price: price,
    ));
    notifyListeners();
    _persist();
  }

  void updateShopItem(
    String id, {
    String? name,
    String? emoji,
    String? description,
    double? price,
  }) {
    final i = _shopItems.indexWhere((it) => it.id == id);
    if (i < 0) return;
    final old = _shopItems[i];
    // 用户改了名称/描述就清掉对应 i18n key,改用用户输入的文本显示。
    _shopItems[i] = ShopItem(
      id: old.id,
      name: name ?? old.name,
      emoji: emoji ?? old.emoji,
      description: description ?? old.description,
      price: price ?? old.price,
      nameKey: name != null ? null : old.nameKey,
      descKey: description != null ? null : old.descKey,
    );
    notifyListeners();
    _persist();
  }

  void removeShopItem(String id) {
    _shopItems.removeWhere((it) => it.id == id);
    notifyListeners();
    _persist();
  }
}
