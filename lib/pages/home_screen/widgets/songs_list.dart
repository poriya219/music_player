import 'dart:math';
import 'dart:typed_data';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controllers/app_controller.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constans.dart';
import '../../play_song_screen/play_song_screen.dart';
import 'controller/songs_list_controller.dart';

class SongsList extends StatelessWidget {
  final List<SongModel> songs;
  SongsList({super.key, required this.songs});

  final controller = Get.put(AppController());
  final songsListController = Get.put(SongsListController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w,vertical: 1.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  final playerController = Get.put(PlayerController());
                  Random random = Random();
                  int index = random.nextInt(songs.length - 1);
                  playerController.player.setShuffleModeEnabled(true);
                  // playerController.initialPlay(path: song.data);
                  Get.to(()=> PlaySongScreen());
                  playerController.sourceListGetter(list: songs,index: index);
                },
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: kBlueColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context)
                        .iconTheme
                        .color,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(
                width: 3.w,
              ),
              const Text('Shuffle playback'),
              const Spacer(),
              GestureDetector(
                onTap: () async{
                  final prefs = await SharedPreferences.getInstance();
                  bool isDark = prefs.getBool('isDark') ?? true;
                  Get.bottomSheet(
                    GetBuilder<SongsListController>(builder: (slController){
                      return Container(
                        width: 90.w,
                        margin: EdgeInsets.symmetric(vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? kBackBlackColor : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 3.h),
                              child: Text('Sort songs',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ),
                            sortCard(title: 'By adding time',value: 0,isDark: isDark),
                            sortCard(title: 'By the numbers of times played',value: 1, isDark: isDark),
                            SizedBox(
                              height: 3.h,
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
                child: const RotatedBox(
                    quarterTurns: 3,
                    child: Icon(EvaIcons.swapOutline)),
              ),
            ],
          ),
        ),
        GetBuilder<SongsListController>(builder: (slController){
          return Expanded(
            child: FutureBuilder(future: songsListController.sortSongList(songs, songsListController.sortValue), builder: (context,AsyncSnapshot snapshot){
              if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                List<SongModel> list = snapshot.data;
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context,index){
                      SongModel song = list[index];
                      return songsCard(list,song,index);
                    });
              }
              else{
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
          );
        }),
      ],
    );
  }

  Widget sortCard({required String title, required int value, required bool isDark}){
    return GestureDetector(
      onTap: () async{
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('SongSortValue', value);
        songsListController.setSortValue(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h,horizontal: 3.w),
        width: 90.w,
        decoration: BoxDecoration(
          color: songsListController.sortValue == value ? kBlueColor.withOpacity(0.3) : Colors.transparent,
        ),
        child: Text(title,style: TextStyle(
          color: songsListController.sortValue == value ? kBlueColor : (isDark ? Colors.white : kGreyColor),
        ),),
      ),
    );
  }

  Widget songsCard(List<SongModel> songsList, SongModel song,int index){
    return GestureDetector(
      onTap: (){
        final playerController = Get.put(PlayerController());
          // playerController.initialPlay(path: song.data);
        print('index: $index');
        Get.to(()=> PlaySongScreen());
        playerController.sourceListGetter(list: songsList,index: index);
      },
      child: Container(
        width: 90.w,
        height: 7.h,
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 1.h,horizontal: 5.w),
        child: Row(
          children: [
            SizedBox(
              width: 6.h,
              height: 6.h,
              child: FutureBuilder(future: controller.getSongImage(song.id), builder: (context, AsyncSnapshot snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                  Uint8List? data = snapshot.data;
                  if(data != null){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(data,
                        width: 6.h,
                        height: 6.h,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(song.title,overflow: TextOverflow.ellipsis,)),
                  Expanded(child: Text(song.artist ?? '<unknown>',overflow: TextOverflow.ellipsis,style: TextStyle(color: kTextGreyColor),)),
                ],
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
            Text(controller.durationGenerator(song.duration ?? 0),style: TextStyle(color: kTextGreyColor),),
          ],
        ),
      ),
    );
  }
}
