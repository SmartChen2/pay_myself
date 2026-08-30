import 'package:audioplayers/audioplayers.dart';

/// 全局音效(金钱音效)
class SoundFx {
  SoundFx._();

  static final AudioPlayer _player = AudioPlayer(playerId: 'sfx')
    ..setReleaseMode(ReleaseMode.stop);

  static final _money = AssetSource('sounds/money-sound.mp3');

  /// 播放金钱音效,失败静默(不影响主流程)
  static Future<void> playMoney() async {
    try {
      await _player.stop();
      await _player.play(_money);
    } catch (_) {
      // 音频设备不可用等情况直接忽略
    }
  }
}
