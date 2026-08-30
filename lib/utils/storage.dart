import 'dart:io';
import 'dart:convert';

/// 简单的 JSON 文件持久化,零外部依赖。
/// 文件位置:
///   - Windows: %APPDATA%/paymyself_state.json
///   - macOS:   ~/Library/Application Support/paymyself_state.json
///   - Linux:   ~/.local/share/paymyself_state.json
///   - 其他/回退: 当前工作目录
class Storage {
  static const _filename = 'paymyself_state.json';

  static Future<File> _file() async {
    final env = Platform.environment;
    String dir;
    if (Platform.isWindows) {
      dir = env['APPDATA'] ?? env['LOCALAPPDATA'] ?? '.';
    } else if (Platform.isMacOS) {
      dir = env['HOME'] != null
          ? '${env['HOME']}/Library/Application Support'
          : '.';
    } else if (Platform.isLinux) {
      dir = env['HOME'] != null ? '${env['HOME']}/.local/share' : '.';
    } else {
      dir = '.';
    }
    final f = File('$dir/$_filename');
    try {
      if (!await f.exists()) await f.create(recursive: true);
    } catch (_) {
      // 回退到当前目录
      return File(_filename);
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
      final base = await _appDataDir();
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

  /// 应用数据目录(与 state json 同目录),失败回退当前目录
  static Future<String> _appDataDir() async {
    final env = Platform.environment;
    String dir;
    if (Platform.isWindows) {
      dir = env['APPDATA'] ?? env['LOCALAPPDATA'] ?? '.';
    } else if (Platform.isMacOS) {
      dir = env['HOME'] != null
          ? '${env['HOME']}/Library/Application Support'
          : '.';
    } else if (Platform.isLinux) {
      dir = env['HOME'] != null ? '${env['HOME']}/.local/share' : '.';
    } else {
      dir = '.';
    }
    try {
      final d = Directory(dir);
      if (!await d.exists()) await d.create(recursive: true);
    } catch (_) {
      return '.';
    }
    return dir;
  }
}
