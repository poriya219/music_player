import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:widget_slider/controller.dart';

class AppController extends GetxController{

  final SliderController sliderController = SliderController();

  bool isSeeking = false;
  setIsSeeking(bool value){
    isSeeking = value;
    update();
  }

  seekSliderController(int index){
    isSeeking = true;
    sliderController.moveTo!.call(index);
    update();
    Timer(const Duration(milliseconds: 300), () {
      setIsSeeking(false);
    });
  }

  Future<Uint8List?> getSongImage(int id) async {
    // DEFAULT: ArtworkFormat.JPEG, 200 and false
    final OnAudioQuery audioQuery = OnAudioQuery();
    Uint8List? data = await audioQuery.queryArtwork(
      id,
      ArtworkType.AUDIO,
      quality: 100,
    );
    return data;
  }

  Future<Uint8List?> getAlbumImage(int id) async {
    // DEFAULT: ArtworkFormat.JPEG, 200 and false
    final OnAudioQuery audioQuery = OnAudioQuery();
    Uint8List? data = await audioQuery.queryArtwork(
      id,
      ArtworkType.ALBUM,
      quality: 100,
    );
    return data;
  }

  Future<Uint8List?> getGenreImage(int id) async {
    // DEFAULT: ArtworkFormat.JPEG, 200 and false
    final OnAudioQuery audioQuery = OnAudioQuery();
    Uint8List? data = await audioQuery.queryArtwork(
      id,
      ArtworkType.GENRE,
      quality: 100,
    );
    return data;
  }

  Future<Uint8List?> getPlaylistImage(int id) async {
    // DEFAULT: ArtworkFormat.JPEG, 200 and false
    final OnAudioQuery audioQuery = OnAudioQuery();
    Uint8List? data = await audioQuery.queryArtwork(
      id,
      ArtworkType.PLAYLIST,
      quality: 100,
    );
    return data;
  }

  Future<Uint8List?> getArtistImage(int id) async {
    // DEFAULT: ArtworkFormat.JPEG, 200 and false
    final OnAudioQuery audioQuery = OnAudioQuery();
    Uint8List? data = await audioQuery.queryArtwork(
      id,
      ArtworkType.ARTIST,
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

  @override
  void onInit() {
    getAppInfo();
    super.onInit();
  }

  getAppInfo() async{
    print('get app info');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    version = packageInfo.version;
    print(appName);
    print(version);
    update();
  }

  String appName = '';
  String version = '';

  int themeValue = 1; /// 1 is darkMode and 0 is lightMode
  setThemeValue(int value){
    themeValue = value;
    update();
  }
}