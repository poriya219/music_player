import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AppController extends GetxController{
  getSongImage(int id) async {
    // DEFAULT: ArtworkFormat.JPEG, 200 and false
    final OnAudioQuery audioQuery = OnAudioQuery();
    Uint8List? data = await audioQuery.queryArtwork(
      id,
      ArtworkType.AUDIO,
      quality: 100,
    );
    return data;
  }

  String durationGenerator(int duration){
    int allSeconds = duration ~/ 1000;
    int min = allSeconds ~/ 60;
    int second = allSeconds % 60;
    return '${min < 10 ? '0$min' : min}:${second < 10 ? '0$second' : second}';
  }
}