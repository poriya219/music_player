import 'dart:convert';

import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongsListController extends GetxController{

  @override
  void onInit() {
    getSavedValues();
    super.onInit();
  }

  getSavedValues() async{
    final prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('SongSortValue') ?? 0;
    setSortValue(value);
  }

  int sortValue = 0;
  setSortValue(int value){
    sortValue = value;
    update();
  }

  Future<List<SongModel>> sortSongList(List<SongModel> list,int value) async{
    print('#');
    print(value);
    final prefs = await SharedPreferences.getInstance();
    String playCounts = prefs.getString('playCount') ?? jsonEncode({});
    Map playCountMap = jsonDecode(playCounts);
    if(value == 0){
      return list;
    }
    else if(value == 1){
      List<SongModel> temp = list.toList();
      temp.sort((a,b)=> (playCountMap[b.id.toString()] ?? 0).compareTo((playCountMap[a.id.toString()] ?? 0)));
      return temp;
    }
    else{
      return list;
    }
  }
}