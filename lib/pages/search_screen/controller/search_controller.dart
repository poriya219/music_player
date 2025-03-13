import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/pages/home_screen/controller/home_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreenController extends GetxController {
  TextEditingController textEditingController = TextEditingController();

  setControllerText(String value) {
    textEditingController.text = value;
    update();
  }

  List<String> history = ['text1', 'text2'];
  setHistory(List<String> value) {
    history = value;
    update();
  }

  List<SongModel> searchedSongs = [];

  setSearchedSongs(List<SongModel> value) {
    searchedSongs = value;
    update();
  }

  searchSongs() {
    final homeController = Get.put(HomeController());
    List<SongModel> temp = [];
    for (SongModel each in homeController.songs) {
      if (each.title.capitalize!.removeAllWhitespace.contains(
              textEditingController.text.capitalize!.removeAllWhitespace) ||
          each.artist!.capitalize!.removeAllWhitespace.contains(
              textEditingController.text.capitalize!.removeAllWhitespace)) {
        temp.add(each);
      }
    }
    setSearchedSongs(temp);
  }

  @override
  void onInit() {
    getHistoryList();
    super.onInit();
  }

  getHistoryList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hl = prefs.getStringList('SearchHistory') ?? [];
    setHistory(hl);
  }
}
