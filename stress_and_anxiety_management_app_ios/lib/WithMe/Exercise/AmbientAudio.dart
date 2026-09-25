import 'package:audioplayers/audioplayers.dart';

/// Serializes native calls so loading cannot outlive pause or screen disposal.
class AmbientAudio {
  AudioPlayer? _player;
  Future<void> _queue = Future.value();
  bool _disposed = false;
  String? _loaded;
  int _revision = 0;
  Future<void> sync({
    required String sound,
    required bool playing,
    required double volume,
  }) {
    final revision = ++_revision;
    _queue = _queue.catchError((Object _) {}).then((_) async {
      if (_disposed || revision != _revision) return;
      if (!playing || sound == 'None') {
        await _player?.pause();
        return;
      }
      final player = _player ??= AudioPlayer();
      if (_loaded != sound) {
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setSource(AssetSource('audio/${sound.toLowerCase()}.wav'));
        _loaded = sound;
      }
      if (_disposed || revision != _revision) return;
      await player.setVolume(volume);
      if (!_disposed && revision == _revision) await player.resume();
    });
    return _queue;
  }

  void dispose() {
    _disposed = true;
    _queue = _queue.catchError((Object _) {}).then((_) async {
      await _player?.dispose();
    });
  }
}
