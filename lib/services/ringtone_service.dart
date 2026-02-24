import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playRingtone() async {
    try {
      if (_isPlaying) return;

      print('🔔 Playing ringtone...');
      // Start vibration pattern
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(
          pattern: [500, 1000], // Vibrate for 500ms, pause for 1000ms
          repeat: 1, // Repeat the pattern once
        );
      }


      // OPTION 1: Use a local ringtone file (Best option)
      // 1. Create folder: assets/audio/
      // 2. Add a ringtone.mp3 file
      // 3. Add to pubspec.yaml: assets/audio/ringtone.mp3
      // await _player.play(AssetSource('audio/ringtone.mp3'));

      // OPTION 2: Use network URL (Simple, no files needed)
      await _player.play(UrlSource('https://assets.mixkit.co/sfx/preview/mixkit-old-telephone-ring-1000.mp3'));

      // Loop the ringtone until answered/declined
      _player.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;

    } catch (e) {
      print('❌ Error playing ringtone: $e');
    }
  }

  Future<void> stopRingtone() async {
    try {
      await _player.stop();
      await Vibration.cancel(); // <-- STOP VIBRATION TOO

      _isPlaying = false;
      print('🔇 Ringtone stopped');
    } catch (e) {
      print('❌ Error stopping ringtone: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}