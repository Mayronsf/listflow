import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {}
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  bool get isPlaying => _player.playing;

  Stream<bool> get playingStream => _player.playingStream;

  void dispose() {
    _player.dispose();
  }
}


