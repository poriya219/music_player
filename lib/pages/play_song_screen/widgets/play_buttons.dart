import 'dart:convert';

import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/controllers/equalizer_ui_controller.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/pages/home_screen/controller/home_controller.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/play_slider.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayButtons extends StatelessWidget {
  final AudioPlayer player;
  final QueryArtworkWidget artwork;
  final String songTitle;
  PlayButtons(
      {super.key,
      required this.player,
      required this.artwork,
      required this.songTitle});

  final pController = Get.find<PlayerController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: [
          Row(
            children: [
              FutureBuilder(
                  future: getCount(songTitle),
                  builder: (context, AsyncSnapshot snapshot) {
                    int pCount = snapshot.data ?? 0;
                    return Text(
                      pCount.toString(),
                      style: TextStyle(
                        fontSize: 17.sp,
                      ),
                    );
                  }),
              SizedBox(
                width: 1.w,
              ),
              Icon(
                EvaIcons.playCircleOutline,
                size: 6.w,
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    List<String> likedSongs =
                        prefs.getStringList('LikedSongs') ?? <String>[];
                    String id = artwork.id.toString();
                    if (likedSongs.contains(id)) {
                      likedSongs.remove(id);
                      kShowToast('Song removed from liked songs');
                    } else {
                      likedSongs.add(id);
                      kShowToast('Song added to liked songs');
                    }
                    await prefs.setStringList('LikedSongs', likedSongs);
                    pController.update();
                  },
                  child: FutureBuilder(
                      future: checkIsLiked(artwork.id.toString()),
                      builder: (context, AsyncSnapshot snapshot) {
                        bool isLiked = snapshot.data ?? false;
                        return Icon(
                          EvaIcons.heart,
                          size: 6.w,
                          color: isLiked ? Colors.redAccent : null,
                        );
                      })),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          PlaySlider(player: player),
          SizedBox(
            height: 2.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: player.shuffleModeEnabledStream,
                  builder: (context, AsyncSnapshot shuffleSnapshot) {
                    if (shuffleSnapshot.hasData) {
                      bool isShuffle = shuffleSnapshot.data ?? false;
                      return GestureDetector(
                        onTap: () {
                          if (isShuffle) {
                            player.setShuffleModeEnabled(false);
                          } else {
                            player.setShuffleModeEnabled(true);
                          }
                        },
                        child: Icon(
                          EvaIcons.shuffle2,
                          size: 9.w,
                          color:
                              isShuffle ? kBlueColor : Get.theme.primaryColor,
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          player.setShuffleModeEnabled(true);
                        },
                        child: Icon(
                          EvaIcons.shuffle2,
                          size: 9.w,
                          color: Get.theme.primaryColor,
                        ),
                      );
                    }
                  }),
              SizedBox(
                width: 4.w,
              ),
              GestureDetector(
                onTap: () {
                  player.seekToPrevious();
                },
                child: Icon(
                  EvaIcons.skipBack,
                  size: 10.w,
                  color: Get.theme.primaryColor,
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              GestureDetector(
                onTap: () {
                  if (player.playing) {
                    player.pause();
                  } else {
                    player.play();
                    final eqController = Get.put(EqualizerUiController());
                    if (eqController.isNull) {
                      eqController.init(i: 1);
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 9.w,
                  backgroundColor: kBlueColor,
                  child: StreamBuilder(
                      stream: player.playingStream,
                      builder: (context, AsyncSnapshot pSnapshot) {
                        if (pSnapshot.hasData) {
                          bool isPlaying = pSnapshot.data;
                          return Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 10.w,
                            color: Colors.white,
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              GestureDetector(
                onTap: () {
                  player.seekToNext();
                },
                child: Icon(
                  EvaIcons.skipForward,
                  size: 10.w,
                  color: Get.theme.primaryColor,
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              StreamBuilder(
                  stream: player.loopModeStream,
                  builder: (context, AsyncSnapshot loopSnapshot) {
                    if (loopSnapshot.hasData) {
                      LoopMode loopMode = loopSnapshot.data;
                      return GestureDetector(
                        onTap: () {
                          if (loopMode == LoopMode.off) {
                            player.setLoopMode(LoopMode.all);
                          } else if (loopMode == LoopMode.all) {
                            player.setLoopMode(LoopMode.one);
                          } else {
                            player.setLoopMode(LoopMode.off);
                          }
                        },
                        child: loopMode == LoopMode.one
                            ? Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Icon(
                                    EvaIcons.repeat,
                                    size: 10.w,
                                    color: loopMode == LoopMode.off
                                        ? Get.theme.primaryColor
                                        : kBlueColor,
                                  ),
                                  CircleAvatar(
                                    radius: 2.w,
                                    backgroundColor: kBlueColor,
                                    child: Center(
                                      child: Text(
                                        '1',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Icon(
                                loopMode == LoopMode.one
                                    ? EvaIcons.repeat
                                    : EvaIcons.repeat,
                                size: 8.w,
                                color: loopMode == LoopMode.off
                                    ? Get.theme.primaryColor
                                    : kBlueColor,
                              ),
                      );
                    } else {
                      return GestureDetector(
                        child: Icon(
                          EvaIcons.repeat,
                          size: 8.w,
                          color: Get.theme.primaryColor,
                        ),
                      );
                    }
                  })
            ],
          ),
        ],
      ),
    );
  }
}

getCount(String title) async {
  int? id;
  final homeController = Get.find<HomeController>();
  for (var each in homeController.songs) {
    if (each.title == title) {
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

Future<bool> checkIsLiked(String id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> likedSongs = prefs.getStringList('LikedSongs') ?? <String>[];
  return likedSongs.contains(id);
}
