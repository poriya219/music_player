import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomeController extends GetxController{

  @override
  void onInit() {
    getSongs();
    super.onInit();
  }

  getSongs() async{
    final OnAudioQuery audioQuery = OnAudioQuery();
    bool granted = await audioQuery.permissionsStatus();
    if(!granted){
      bool status = await audioQuery.permissionsRequest();
      if(status){
        getLists();
      }
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          // This is just a basic example. For real apps, you must show some
          // friendly dialog box before call the request method.
          // This is very important to not harm the user experience
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
    }
    else{
      getLists();
    }
  }

  getLists() async{
    final OnAudioQuery audioQuery = OnAudioQuery();
    List<AlbumModel> al = await audioQuery.queryAlbums();
    List<ArtistModel> ar = await audioQuery.queryArtists();
    List<PlaylistModel> pl = await audioQuery.queryPlaylists();
    List<GenreModel> ge = await audioQuery.queryGenres();
    List<SongModel> so = await audioQuery.querySongs(sortType: SongSortType.DATE_ADDED,orderType: OrderType.DESC_OR_GREATER);
    songs = so;
    albums = al;
    artists = ar;
    playLists = pl;
    genres = ge;
    update();
  }

  List<SongModel> songs = [];
  List<AlbumModel> albums = [];
  List<ArtistModel> artists = [];
  List<PlaylistModel> playLists = [];
  List<GenreModel> genres = [];


  String selectedFilter = 'Song';
  setSelectedFilter(String value){
    selectedFilter = value;
    update();
  }

}