import 'dart:convert';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/constans.dart';
import 'package:music_player/controllers/lyrics_controller.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/controller/home_controller.dart';

class PlaySongScreen extends StatelessWidget {
  PlaySongScreen({super.key});

  final controller = Get.put(PlayerController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PlayerController>(builder: (pController) {
        return StreamBuilder(stream: controller.player.currentIndexStream, builder: (context,AsyncSnapshot iSnapshot){
          if(iSnapshot.hasData){
            final lyricsController = Get.put(LyricsController());
            int cIndex = iSnapshot.data ?? 0;
            AudioSource cSong = controller.playlist[cIndex];
            return PageTransitionSwitcher(
              reverse: true,
              transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  ) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: StreamBuilder(
                  stream: controller.player.sequenceStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      List<IndexedAudioSource> list = snapshot.data ?? <IndexedAudioSource>[];
                      QueryArtworkWidget artwork =
                          list[cIndex].tag.artwork;
                      String songTitle = list[cIndex].tag.title;
                      String songArtist = list[cIndex].tag.artist;
                      lyricsController.getLyrics(title: songTitle, artist: songArtist);

                      return Stack(
                        children: [
                          SizedBox(
                            width: 100.w,
                            height: 80.h,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black, Colors.transparent],
                                ).createShader(
                                    Rect.fromLTRB(0, 0, rect.width, rect.height));
                              },
                              blendMode: BlendMode.dstIn,
                              child: artwork,
                            ),
                          ),
                          SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 2.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Get.back();
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black.withOpacity(0.3),
                                          radius: 6.w,
                                          child: Center(
                                            child: Icon(
                                              EvaIcons.arrowIosBack,
                                              color: Theme.of(context).primaryColorLight,
                                              size: 7.w,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(songTitle,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.sp,
                                              ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(songArtist,
                                                style: TextStyle(
                                                  color: kTextGreyColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // CircleAvatar(
                                      //   backgroundColor: Colors.black.withOpacity(0.3),
                                      //   radius: 6.w,
                                      //   child: Icon(
                                      //     EvaIcons.moreHorizontal,
                                      //     color: Theme.of(context).primaryColorLight,
                                      //     size: 7.w,
                                      //   ),
                                      // )
                                      SizedBox(
                                        width: 6.w,
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                GetBuilder<LyricsController>(builder: (lController){
                                  return SizedBox(
                                    width: 80.w,
                                    height: 30.h,
                                    child: ShaderMask(
                                      shaderCallback: (rect) {
                                        return const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.black, Colors.transparent],
                                        ).createShader(
                                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            ListView.builder(
                                                itemCount: lyricsController.lyricsString == null ? 0 : lyricsController.lyricsString!.split('\n').length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder: (context,index){
                                                  List<String> stList = lyricsController.lyricsString == null ? <String>[] : lyricsController.lyricsString!.split('\n');
                                                  return Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 1.h),
                                                    child: Text(stList[index],
                                                    textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Theme.of(context).iconTheme.color,
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.w500
                                                      ),
                                                    ),
                                                  );

                                                }),
                                            SizedBox(
                                              height: 7.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          FutureBuilder(future: getCount(songTitle), builder: (context, AsyncSnapshot snapshot){
                                            int pCount = snapshot.data ?? 0;
                                            return Text(pCount.toString(),
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                            ),
                                            );
                                          }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          Icon(EvaIcons.playCircleOutline,size: 6.w,),
                                          const Spacer(),
                                          GestureDetector(
                                              onTap: (){
                                                kShowToast('ASAP');
                                              },
                                              child: Icon(EvaIcons.heart,size: 6.w,color: Colors.redAccent,)),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          StreamBuilder(stream: controller.player.shuffleModeEnabledStream, builder: (context, AsyncSnapshot shuffleSnapshot){
                                            if(shuffleSnapshot.hasData){
                                              bool isShuffle = shuffleSnapshot.data ?? false;
                                              return GestureDetector(
                                                onTap: (){
                                                  if(isShuffle){
                                                    controller.player.setShuffleModeEnabled(false);
                                                  }
                                                  else{
                                                    controller.player.setShuffleModeEnabled(true);
                                                  }
                                                },
                                                child: Icon(
                                                  EvaIcons.shuffle2,
                                                  size: 10.w,
                                                  color: isShuffle ? kBlueColor : Get.theme.primaryColor,
                                                ),
                                              );
                                            }
                                            else{
                                              return GestureDetector(
                                                onTap: (){
                                                  controller.player.setShuffleModeEnabled(true);
                                                },
                                                child: Icon(
                                                  EvaIcons.shuffle2,
                                                  size: 10.w,
                                                  color: Get.theme.primaryColor,
                                                ),
                                              );
                                            }
                                          }),
                                          GestureDetector(
                                            onTap: (){
                                              controller.player.seekToPrevious();
                                            },
                                            child: Icon(
                                              EvaIcons.skipBack,
                                              size: 10.w,
                                              color: Get.theme.primaryColor,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              if(controller.player.playing){
                                                controller.player.pause();
                                              }
                                              else{
                                                controller.player.play();
                                              }
                                            },
                                            child: CircleAvatar(
                                              radius: 8.w,
                                              backgroundColor: kBlueColor,
                                              child: StreamBuilder(stream: controller.player.playingStream, builder: (context,AsyncSnapshot pSnapshot){
                                                if(pSnapshot.hasData){
                                                  bool isPlaying = pSnapshot.data;
                                                  return Icon(
                                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                                    size: 10.w,
                                                    color: Colors.white,
                                                  );
                                                }
                                                else{
                                                  return const SizedBox();
                                                }
                                              }),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              controller.player.seekToNext();
                                            },
                                            child: Icon(
                                              EvaIcons.skipForward,
                                              size: 10.w,
                                              color: Get.theme.primaryColor,
                                            ),
                                          ),
                                          StreamBuilder(stream: controller.player.loopModeStream, builder: (context, AsyncSnapshot loopSnapshot){
                                            if(loopSnapshot.hasData){
                                              LoopMode loopMode = loopSnapshot.data;
                                              return GestureDetector(
                                                onTap: (){
                                                  if( loopMode == LoopMode.off){
                                                    controller.player.setLoopMode(LoopMode.all);
                                                  }
                                                  else if( loopMode == LoopMode.all){
                                                    controller.player.setLoopMode(LoopMode.one);
                                                  }
                                                  else{
                                                    controller.player.setLoopMode(LoopMode.off);
                                                  }
                                                },
                                                child: loopMode == LoopMode.one ? Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Icon(
                                                      EvaIcons.repeat,
                                                      size: 10.w,
                                                      color: loopMode == LoopMode.off ? Get.theme.primaryColor : kBlueColor,
                                                    ),
                                                    CircleAvatar(
                                                      radius: 2.w,
                                                      backgroundColor: kBlueColor,
                                                      child: Center(
                                                        child: Text('1',style: TextStyle(color: Colors.white,fontSize: 12.sp),),
                                                      ),
                                                    ),
                                                  ],
                                                ) : Icon(
                                                  loopMode == LoopMode.one ? EvaIcons.repeat : EvaIcons.repeat,
                                                  size: 10.w,
                                                  color: loopMode == LoopMode.off ? Get.theme.primaryColor : kBlueColor,
                                                ),
                                              );
                                            }
                                            else{
                                              return GestureDetector(
                                                child: Icon(
                                                  EvaIcons.repeat,
                                                  size: 10.w,
                                                  color: Get.theme.primaryColor,
                                                ),
                                              );
                                            }
                                          })
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 4.h,
                                ),
                                StreamBuilder(
                                    stream: controller.player.durationStream,
                                    builder: (context, AsyncSnapshot dSnapshot) {
                                      if (dSnapshot.hasData) {
                                        Duration? duration = dSnapshot.data;
                                        if (duration != null) {
                                          return StreamBuilder(
                                              stream:
                                              controller.player.positionStream,
                                              builder:
                                                  (context, AsyncSnapshot pSnapshot) {
                                                if (pSnapshot.hasData) {
                                                  Duration position = pSnapshot.data;
                                                  return Column(
                                                    children: [
                                                      Slider(
                                                        thumbColor: kBlueColor,
                                                        activeColor: kBlueColor,
                                                        inactiveColor: kTextGreyColor,
                                                        value:
                                                        position.inSeconds.toDouble(),
                                                        onChanged: (value) {
                                                          controller.player.seek(Duration(seconds: value.toInt()));
                                                        },
                                                        max:
                                                        duration.inSeconds.toDouble(),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 7.w),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('${position.inMinutes < 10 ? '0${position.inMinutes}' : position.inMinutes}:${position.inSeconds % 60 < 10 ? '0${position.inSeconds % 60}' : position.inSeconds % 60}',
                                                            style: TextStyle(
                                                              color: Get.theme.primaryColor,
                                                              fontSize: 14.sp,
                                                              fontWeight: FontWeight.w500
                                                            ),
                                                            ),
                                                            Text('${duration.inMinutes < 10 ? '0${duration.inMinutes}' : duration.inMinutes}:${duration.inSeconds % 60 < 10 ? '0${duration.inSeconds % 60}' : duration.inSeconds % 60}',
                                                              style: TextStyle(
                                                                  color: Get.theme.primaryColor,
                                                                  fontSize: 14.sp,
                                                                  fontWeight: FontWeight.w500
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return const SizedBox();
                                                }
                                              });
                                        } else {
                                          return const SizedBox();
                                        }
                                      } else {
                                        return const SizedBox();
                                      }
                                    }),
                                SizedBox(
                                  height: 4.h,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            );
          }
          else{
            return const Center(child: CircularProgressIndicator(),);
          }
        });
      }),
    );
  }

  getCount(String title) async{
    int? id;
    final homeController = Get.find<HomeController>();
    for(var each in homeController.songs){
      if(each.title == title){
        id = each.id;
        break;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    String playCountsString = prefs.getString('playCount') ?? jsonEncode({});
    Map map = jsonDecode(playCountsString);
    map.putIfAbsent(id.toString(), () => 0);
    int count = map[id.toString()] ?? 0;
    return count;
  }
}
