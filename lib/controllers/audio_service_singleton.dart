import 'package:MusicFlow/controllers/player_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioServiceSingleton {
  static final AudioServiceSingleton _instance =
      AudioServiceSingleton._internal();
  late final IsolatedAudioHandler _audioHandler;

  factory AudioServiceSingleton() => _instance;

  AudioServiceSingleton._internal();

  Future<void> init() async {
    // if (kDebugMode) {
    //   AudioHandler proxyAudioHandler = await IsolatedAudioHandler.lookup(
    //     portName: 'my_audio_handler',
    //   );

    //   await proxyAudioHandler.stop();
    //   await Future.delayed(const Duration(milliseconds: 300));
    // }
    _audioHandler = await AudioService.init(
      builder: () => IsolatedAudioHandler(
        PlayerService(),
        portName: 'my_audio_handler',
      ),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'play_channel_group',
        androidNotificationChannelName: 'play channel',
        androidStopForegroundOnPause: false,
      ),
    );
  }

  IsolatedAudioHandler get handler => _audioHandler;
}
