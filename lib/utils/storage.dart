import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

/// 简单的 JSON 文件持久化,零外部依赖(移动端使用 path_provider)。
/// 文件位置:
///   - Android/iOS: 应用私有数据目录(getApplicationSupportDirectory)
///   - Windows: %APPDATA%/paymyself_state.json
///   - macOS:   ~/Library/Application Support/paymyself_state.json
///   - Linux:   ~/.local/share/paymyself_state.json
///   - 其他/回退: 当前工作目录
class Storage {
  static const _filename = 'paymyself_state.json';

  /// 决定持久化根目录:移动端走应用私有目录(稳定且可写),桌面端沿用原有路径。
  static Future<String> _baseDir() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // 应用私有的"支持文件"目录,卸载前一直有效,跨启动稳定。
      return (await getApplicationSupportDirectory()).path;
    }
    final env = Platform.environment;
    if (Platform.isWindows) {
      return env['APPDATA'] ?? env['LOCALAPPDATA'] ?? '.';
    } else if (Platform.isMacOS) {
      return env['HOME'] != null
          ? '${env['HOME']}/Library/Application Support'
          : '.';
    } else if (Platform.isLinux) {
      return env['HOME'] != null ? '${env['HOME']}/.local/share' : '.';
    } else {
      return '.';
    }
  }

  /// 确保持久化目录存在并返回其路径。
  static Future<String> _ensureDir() async {
    try {
      final base = await _baseDir();
      final d = Directory(base);
      if (!await d.exists()) await d.create(recursive: true);
      return base;
    } catch (_) {
      // 回退:应用文档目录(仅移动端有,桌面端继续用当前目录)
      try {
        final base = (await getApplicationDocumentsDirectory()).path;
        final d = Directory(base);
        if (!await d.exists()) await d.create(recursive: true);
        return base;
      } catch (_) {
        return '.';
      }
    }
  }

  /// 返回状态文件(自动创建)。
  static Future<File> _file() async {
    final base = await _ensureDir();
    final f = File('$base/$_filename');
    try {
      if (!await f.exists()) await f.create(recursive: true);
    } catch (_) {
      // 创建失败也不影响后续读写尝试
    }
    return f;
  }

  /// 读取 JSON,失败返回空 map
  static Future<Map<String, dynamic>> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return {};
      final s = await f.readAsString();
      if (s.trim().isEmpty) return {};
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// 写入 JSON,失败静默
  static Future<void> save(Map<String, dynamic> data) async {
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {
      // 持久化失败不影响运行
    }
  }

  /// 把选中的头像图片复制到应用数据目录,返回稳定路径。
  /// 失败返回 null。复制后即便原文件被删,头像依然可用。
  static Future<String?> copyAvatar(File source) async {
    try {
      final base = await _ensureDir();
      final srcPath = source.path;
      final dot = srcPath.lastIndexOf('.');
      final ext = dot >= 0 ? srcPath.substring(dot).toLowerCase() : '.jpg';
      final dest = File('$base/paymyself_avatar$ext');
      await dest.writeAsBytes(await source.readAsBytes(), flush: true);
      return dest.path;
    } catch (_) {
      return null;
    }
  }
}