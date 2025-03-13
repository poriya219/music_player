import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/controllers/app_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    getSongs();
    super.onInit();
  }

  bool isGrantedPermission = false;
  setIsGranted() {
    isGrantedPermission = true;
    update();
  }

  getSongs() async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    bool granted = await audioQuery.permissionsStatus();
    if (!granted) {
      bool status = await audioQuery.permissionsRequest();
      if (status) {
        getLists();
      }
    } else {
      getLists();
    }
  }

  resetPlaylists() async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    List<PlaylistModel> pl = await audioQuery.queryPlaylists();
    playLists = pl;
    update();
  }

  getLists() async {
    setIsGranted();
    final OnAudioQuery audioQuery = OnAudioQuery();
    List<AlbumModel> al = await audioQuery.queryAlbums();
    List<ArtistModel> ar = await audioQuery.queryArtists();
    List<PlaylistModel> pl = await audioQuery.queryPlaylists();
    List<GenreModel> ge = await audioQuery.queryGenres();
    List<SongModel> so = await audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER);
    songs = so;
    albums = al;
    artists = ar;
    playLists = pl;
    genres = ge;
    update();
    getArtworks();
  }

  List<SongModel> songs = [];
  List<AlbumModel> albums = [];
  List<ArtistModel> artists = [];
  List<PlaylistModel> playLists = [];
  List<GenreModel> genres = [];

  String selectedFilter = 'Song';
  setSelectedFilter(String value) {
    selectedFilter = value;
    update();
  }

  getArtworks() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tp = tempDir.path;
    List<int> ids = List.generate(songs.length, (index) => songs[index].id);
    var rootToken = RootIsolateToken.instance!;
    final ByteData bytes = await rootBundle.load('assets/images/gd.png');
    final Uint8List listBytes = bytes.buffer.asUint8List();
    Isolate.spawn((List message) async {
      List<int> list = message[0] ?? [];
      String tempPath = message[1] ?? '';
      BackgroundIsolateBinaryMessenger.ensureInitialized(message[2]);
      Uint8List defaultData = message[3] ?? Uint8List(0);
      final OnAudioQuery audioQuery = OnAudioQuery();
      for (int each in list) {
        var filePath = '$tempPath/file_$each.png';
        Uint8List? data = await audioQuery.queryArtwork(
          each,
          ArtworkType.AUDIO,
          quality: 100,
        );
        await File(filePath).writeAsBytes(data ?? defaultData);
      }
    }, [ids, tp, rootToken, listBytes]);
  }
}
