// services/audio_service.dart
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playEmergencySound() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.speech());

      await _player.setAsset('assets/audio/emergency_alarm.mp3');
      await _player.setLoopMode(LoopMode.all);
      await _player.play();
    } catch (e) {
      print('Error playing emergency sound: $e');
    }
  }

  Future<void> stopEmergencySound() async {
    await _player.stop();
    await _player.dispose();
  }

  Future<void> playFakeRingtone() async {
    try {
      await _player.setAsset('assets/audio/ringtone.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      print('Error playing ringtone: $e');
    }
  }
}