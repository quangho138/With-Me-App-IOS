import 'package:audioplayers/audioplayers.dart';

/// One 14-second breath track, aligned to the exercise's elapsed clock.
class SighAudio {
  AudioPlayer? _player;
  Future<void> _queue = Future.value();
  int _revision = 0;
  bool _disposed = false;
  bool _loaded = false;
  Future<void> sync({required bool playing, required Duration elapsed}) {
    final revision = ++_revision;
    return _queue = _queue.catchError((Object _) {}).then((_) async {
      if (_disposed || revision != _revision) return;
      if (!playing) {
        await _player?.pause();
        return;
      }
      final player = _player ??= AudioPlayer();
      if (!_loaded) {
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setSource(AssetSource('audio/sigh-breath.wav'));
        await player.setVolume(.65);
        _loaded = true;
      }
      if (_disposed || revision != _revision) return;
      await player.seek(
        Duration(microseconds: elapsed.inMicroseconds % 14000000),
      );
      if (!_disposed && revision == _revision) await player.resume();
    });
  }

  void dispose() {
    _disposed = true;
    ++_revision;
    _queue = _queue.catchError((Object _) {}).then((_) async {
      await _player?.dispose();
    });
  }
}
