import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:get/get.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_slider/controller.dart';

class AppController extends GetxController {
  final SliderController sliderController = SliderController();

  bool isSeeking = false;
  setIsSeeking(bool value) {
    isSeeking = value;
    update();
  }

  seekSliderController(int index) {
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

  String durationGenerator(int duration) {
    int allSeconds = duration ~/ 1000;
    int min = allSeconds ~/ 60;
    int second = allSeconds % 60;
    return '${min < 10 ? '0$min' : min}:${second < 10 ? '0$second' : second}';
  }

  @override
  void onInit() {
    getAppInfo();
    getLastPlay();
    getLocale();
    getTheme();
    super.onInit();
  }

  getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDark') ?? (Get.isDarkMode);
    int value = isDark ? 1 : 0;
    setThemeValue(value);
  }

  getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String locale = prefs.getString('locale') ?? 'en';
    setSelectedLocale(locale);
  }

  getAppInfo() async {
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

  int themeValue = 1;

  /// 1 is darkMode and 0 is lightMode
  setThemeValue(int value) {
    themeValue = value;
    update();
  }

  getLastPlay() async {
    final prefs = await SharedPreferences.getInstance();
    int? index = prefs.getInt('last_play_index');
    String? list = prefs.getString('last_play_list');
    if (index != null && list != null) {
      List data = jsonDecode(list);
      List<SongModel> songModels = await Isolate.run(() {
        List<SongModel> temp = [];
        for (var each in data) {
          temp.add(SongModel(each));
        }
        return temp;
      });
      final playerController = Get.put(PlayerController());
      playerController.sourceListGetter(
          list: songModels, index: index, play: false);
    }
  }

  String selectedLocale = "en";
  setSelectedLocale(String value) {
    selectedLocale = value;
    update();
  }
}
