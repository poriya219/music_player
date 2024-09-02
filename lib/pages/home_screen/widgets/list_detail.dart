import 'dart:math';
import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/player_controller.dart';
import '../../play_song_screen/play_song_screen.dart';
import '../controller/home_controller.dart';

class ListDetail extends StatelessWidget {
  final dynamic model;
  final ListDetailMode mode;
  ListDetail({super.key, required this.model, required this.mode});

  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              EvaIcons.arrowBack,
              color: Theme.of(context).iconTheme.color,
            )),
      ),
      body: SafeArea(child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: FutureBuilder(future: getList(mode: mode,model: model), builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
            List<SongModel> list = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30.w,
                          height: 30.w,
                          child: FutureBuilder(future: getImage(mode: mode, id: mode == ListDetailMode.song ? (model.isEmpty ? 0 : model[0].id) : model.id),
                              builder: (context, AsyncSnapshot snapshot){
                            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                              Uint8List? data = snapshot.data;
                              if(data != null){
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(data,
                                    width: 30.w,
                                    height: 30.w,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              else{
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset('assets/images/bd.png',
                                    width: 6.h,
                                    height: 6.h,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            }
                            else{
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset('assets/images/gd.png',
                                  width: 6.h,
                                  height: 6.h,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                          }),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        SizedBox(
                          width: 55.w,
                          height: 30.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(getTitle(mode: mode, model: model)[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: kTextGreyColor),
                              ),
                              Text(getTitle(mode: mode, model: model)[1],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  InkWell(
                    onTap: (){
                      if(list.isNotEmpty){
                        final playerController = Get.put(PlayerController());
                        Random random = Random();
                        int index = list.length > 1 ? random.nextInt(list.length - 1) : 1;
                        playerController.player.setShuffleModeEnabled(true);
                        Get.to(()=> PlaySongScreen());
                        playerController.sourceListGetter(list: list,index: index);
                      }
                    },
                    child: Container(
                      width: 90.w,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 7.w),
                            child: Icon(EvaIcons.shuffle2,
                              size: 7.w,
                            ),
                          ),
                          Expanded(child: Center(child: Text('Shuffle Play',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          ),))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  ListView.builder(
                      itemCount: list.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        return card(songsList: list,index: index);
                      },),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            );
          }
          else{
            return const SizedBox();
          }
        }),
      ),),
    );
  }

  Widget card ({required List<SongModel> songsList, required int index}){
    SongModel song = songsList[index];
    return Padding(padding: EdgeInsets.symmetric(vertical: 1.h),
      child: GestureDetector(
        onTap: (){
          final playerController = Get.put(PlayerController());
          Get.to(()=> PlaySongScreen());
          playerController.sourceListGetter(list: songsList,index: index);
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 0.2.h,
                    ),
                    Text(song.artist ?? 'Unknown artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: kTextGreyColor),
                    ),
                  ],
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customButton: Icon(
                    Icons.more_vert,
                    size: 6.w,
                    // color: Colors.red,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: mode == ListDetailMode.playlist ? 0 : 1,
                      child: Text(mode == ListDetailMode.playlist ? 'Remove from playlist' : 'Add to playlist'),
                    ),
                  ],
                  onChanged: (value) async{
                    switch(value){
                      case 0:
                        final OnAudioQuery audioQuery = OnAudioQuery();
                        print(model.id);
                        print(song.id);
                        bool status = await audioQuery.removeFromPlaylist(model.id, song.id);
                        print('status is: $status');
                        // Get.back();
                        kShowToast('Song removed from playlist');
                        final controller = Get.find<HomeController>();
                        controller.resetPlaylists();
                      case 1:
                        final homeController = Get.find<HomeController>();
                        kShowDialog(
                            verticalPadding: 30.h,
                            child: ListView.builder(
                              itemCount: homeController.playLists.length,
                              shrinkWrap: true,
                              itemBuilder: (context,index){
                                PlaylistModel playlist = homeController.playLists[index];
                                return Card(
                                  child: InkWell(
                                    onTap: (){
                                      print(playlist.id);
                                      print(song.id);
                                      kAddToPlaylist(playlistId: playlist.id, audioId: song.id);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 1.5.h),
                                      child: Text(
                                        playlist.playlist,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ));
                    }
                  },
                  dropdownStyleData: DropdownStyleData(
                    width: 50.w,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      // color: Colors.redAccent,
                    ),
                    offset: const Offset(0, 8),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    // customHeights: [
                    //   ...List<double>.filled(MenuItems.firstItems.length, 48),
                    //   8,
                    //   ...List<double>.filled(MenuItems.secondItems.length, 48),
                    // ],
                    padding: const EdgeInsets.only(left: 16, right: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<String> getTitle({required ListDetailMode mode, required dynamic model}){
    switch(mode){
      case ListDetailMode.album:
        return ['ALBUM - ${model.numOfSongs} SONG','${model.album}'];
      case ListDetailMode.artist:
        return ['ARTIST - ${model.numberOfTracks} SONG','${model.artist}'];
      case ListDetailMode.genre:
        return ['GENRE - ${model.numOfSongs} SONG','${model.genre}'];
      case ListDetailMode.playlist:
        return ['Playlist - ${model.numOfSongs} SONG','${model.playlist}'];
        case ListDetailMode.song:
        return ['Liked Songs - ${model.length} SONG',''];
      default:
        return ['',''];
    }
  }

  Future getImage({required ListDetailMode mode, required int id}) async{
    switch(mode){
      case ListDetailMode.album:
        return controller.getAlbumImage(id);
      case ListDetailMode.artist:
        return controller.getArtistImage(id);
      case ListDetailMode.genre:
        return controller.getGenreImage(id);
      case ListDetailMode.playlist:
        return controller.getPlaylistImage(id);
      default:
        return controller.getSongImage(id);
    }
  }

  Future<List<SongModel>> getList({required dynamic model, required ListDetailMode mode}) async{
    try{
      if(mode == ListDetailMode.song){
        return model;
      }
      else{
        OnAudioQuery onAudioQuery = OnAudioQuery();
        var list = await onAudioQuery.queryAudiosFrom(getType(mode: mode), model.id);
        return list;
      }
    }
        catch(e){
      return [];
        }
  }

  AudiosFromType getType({required ListDetailMode mode}){
    switch(mode){
      case ListDetailMode.genre:
        return AudiosFromType.GENRE_ID;
      case ListDetailMode.artist:
        return AudiosFromType.ARTIST_ID;
      case ListDetailMode.album:
        return AudiosFromType.ALBUM_ID;
      case ListDetailMode.playlist:
        return AudiosFromType.PLAYLIST;
      default:
        return AudiosFromType.ALBUM_ID;
    }
  }
}

enum ListDetailMode {
  artist,
  album,
  genre,
  playlist,
  song,
}
