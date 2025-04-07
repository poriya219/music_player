import 'dart:convert';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/controllers/lyrics_controller.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/controllers/similar_controller.dart';
import 'package:MusicFlow/pages/play_song_screen/show_song_controls.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:widget_slider/widget_slider.dart';

import '../home_screen/controller/home_controller.dart';

class PlaySongScreen extends StatelessWidget {
  PlaySongScreen({super.key});

  final controller = Get.put(PlayerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PlayerController>(builder: (pController) {
        return StreamBuilder(
            stream: controller.player.currentIndexStream,
            builder: (context, AsyncSnapshot iSnapshot) {
              final lyricsController = Get.put(LyricsController());
              int cIndex = iSnapshot.data ?? 0;
              // AudioSource cSong = controller.playlist[cIndex];
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
                      List<IndexedAudioSource> list =
                          snapshot.data ?? <IndexedAudioSource>[];
                      QueryArtworkWidget artwork = iSnapshot.hasData
                          ? QueryArtworkWidget(
                              artworkBorder: BorderRadius.circular(20),
                              artworkQuality: FilterQuality.high,
                              nullArtworkWidget: Image.asset(
                                'assets/images/gd.png',
                                height: 80.h,
                                fit: BoxFit.fitHeight,
                              ),
                              size: 5000,
                              quality: 100,
                              format: ArtworkFormat.JPEG,
                              id: int.parse(list[cIndex].tag.id),
                              type: ArtworkType.AUDIO)
                          : const QueryArtworkWidget(
                              id: 0, type: ArtworkType.AUDIO);
                      String songTitle = iSnapshot.hasData
                          ? list[cIndex].tag.title
                          : 'Unknown';
                      String songArtist = iSnapshot.hasData
                          ? list[cIndex].tag.artist
                          : 'Unknown';
                      lyricsController.getLyrics(
                          title: songTitle, artist: songArtist);
                      final similarController = Get.find<SimilarController>();
                      similarController.getSimilarTracks(
                          title: songTitle, artist: songArtist);
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100.h,
                              child: Stack(
                                children: [
                                  WidgetSlider(
                                      itemCount: 3,
                                      proximity: 1,
                                      fixedSize: 80.h,
                                      controller: controller.sliderController,
                                      onMove: (i) {
                                        if (!controller.isSeeking) {
                                          controller.seekSliderController(1);
                                          if (i == 2) {
                                            controller.player.seekToNext();
                                          } else if (i == 0) {
                                            controller.player.seekToPrevious();
                                          }
                                        }
                                      },
                                      transformCurve: const ElasticOutCurve(),
                                      sizeDistinction: 0.99,
                                      itemBuilder:
                                          (context, index, activeIndex) {
                                        return ShowSongControls(
                                          artwork: artwork,
                                        );
                                      }),
                                  Container(
                                    height: 15.h,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black,
                                          Colors.transparent
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.back();
                                                },
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.black
                                                      .withOpacity(0.3),
                                                  radius: 6.w,
                                                  child: Center(
                                                    child: Icon(
                                                      EvaIcons.arrowIosBack,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                      size: 7.w,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4.w),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        songTitle,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17.sp,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        songArtist,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16.sp,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                        GetBuilder<LyricsController>(
                                            builder: (lController) {
                                          return SizedBox(
                                            width: 80.w,
                                            height: 30.h,
                                            child: ShaderMask(
                                              shaderCallback: (rect) {
                                                return const LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black,
                                                    Colors.transparent
                                                  ],
                                                ).createShader(Rect.fromLTRB(
                                                    0,
                                                    0,
                                                    rect.width,
                                                    rect.height));
                                              },
                                              blendMode: BlendMode.dstIn,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    ListView.builder(
                                                        itemCount: lyricsController
                                                                    .lyricsString ==
                                                                null
                                                            ? 0
                                                            : lyricsController
                                                                .lyricsString!
                                                                .length,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        1.h),
                                                            child: Text(
                                                              lyricsController
                                                                      .lyricsString![
                                                                  index],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .color,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  FutureBuilder(
                                                      future:
                                                          getCount(songTitle),
                                                      builder: (context,
                                                          AsyncSnapshot
                                                              snapshot) {
                                                        int pCount =
                                                            snapshot.data ?? 0;
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
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        List<String>
                                                            likedSongs =
                                                            prefs.getStringList(
                                                                    'LikedSongs') ??
                                                                <String>[];
                                                        String id = artwork.id
                                                            .toString();
                                                        if (likedSongs
                                                            .contains(id)) {
                                                          likedSongs.remove(id);
                                                          kShowToast(
                                                              'Song removed from liked songs');
                                                        } else {
                                                          likedSongs.add(id);
                                                          kShowToast(
                                                              'Song added to liked songs');
                                                        }
                                                        await prefs
                                                            .setStringList(
                                                                'LikedSongs',
                                                                likedSongs);
                                                        pController.update();
                                                      },
                                                      child: FutureBuilder(
                                                          future: checkIsLiked(
                                                              artwork.id
                                                                  .toString()),
                                                          builder: (context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                            bool isLiked =
                                                                snapshot.data ??
                                                                    false;
                                                            return Icon(
                                                              EvaIcons.heart,
                                                              size: 6.w,
                                                              color: isLiked
                                                                  ? Colors
                                                                      .redAccent
                                                                  : null,
                                                            );
                                                          })),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  StreamBuilder(
                                                      stream: controller.player
                                                          .shuffleModeEnabledStream,
                                                      builder: (context,
                                                          AsyncSnapshot
                                                              shuffleSnapshot) {
                                                        if (shuffleSnapshot
                                                            .hasData) {
                                                          bool isShuffle =
                                                              shuffleSnapshot
                                                                      .data ??
                                                                  false;
                                                          return GestureDetector(
                                                            onTap: () {
                                                              if (isShuffle) {
                                                                controller
                                                                    .player
                                                                    .setShuffleModeEnabled(
                                                                        false);
                                                              } else {
                                                                controller
                                                                    .player
                                                                    .setShuffleModeEnabled(
                                                                        true);
                                                              }
                                                            },
                                                            child: Icon(
                                                              EvaIcons.shuffle2,
                                                              size: 10.w,
                                                              color: isShuffle
                                                                  ? kBlueColor
                                                                  : Get.theme
                                                                      .primaryColor,
                                                            ),
                                                          );
                                                        } else {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              controller.player
                                                                  .setShuffleModeEnabled(
                                                                      true);
                                                            },
                                                            child: Icon(
                                                              EvaIcons.shuffle2,
                                                              size: 10.w,
                                                              color: Get.theme
                                                                  .primaryColor,
                                                            ),
                                                          );
                                                        }
                                                      }),
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller.player
                                                          .seekToPrevious();
                                                    },
                                                    child: Icon(
                                                      EvaIcons.skipBack,
                                                      size: 10.w,
                                                      color: Get
                                                          .theme.primaryColor,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (controller
                                                          .player.playing) {
                                                        controller.player
                                                            .pause();
                                                      } else {
                                                        controller.player
                                                            .play();
                                                      }
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 8.w,
                                                      backgroundColor:
                                                          kBlueColor,
                                                      child: StreamBuilder(
                                                          stream: controller
                                                              .player
                                                              .playingStream,
                                                          builder: (context,
                                                              AsyncSnapshot
                                                                  pSnapshot) {
                                                            if (pSnapshot
                                                                .hasData) {
                                                              bool isPlaying =
                                                                  pSnapshot
                                                                      .data;
                                                              return Icon(
                                                                isPlaying
                                                                    ? Icons
                                                                        .pause
                                                                    : Icons
                                                                        .play_arrow,
                                                                size: 10.w,
                                                                color: Colors
                                                                    .white,
                                                              );
                                                            } else {
                                                              return const SizedBox();
                                                            }
                                                          }),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller.player
                                                          .seekToNext();
                                                    },
                                                    child: Icon(
                                                      EvaIcons.skipForward,
                                                      size: 10.w,
                                                      color: Get
                                                          .theme.primaryColor,
                                                    ),
                                                  ),
                                                  StreamBuilder(
                                                      stream: controller.player
                                                          .loopModeStream,
                                                      builder: (context,
                                                          AsyncSnapshot
                                                              loopSnapshot) {
                                                        if (loopSnapshot
                                                            .hasData) {
                                                          LoopMode loopMode =
                                                              loopSnapshot.data;
                                                          return GestureDetector(
                                                            onTap: () {
                                                              if (loopMode ==
                                                                  LoopMode
                                                                      .off) {
                                                                controller
                                                                    .player
                                                                    .setLoopMode(
                                                                        LoopMode
                                                                            .all);
                                                              } else if (loopMode ==
                                                                  LoopMode
                                                                      .all) {
                                                                controller
                                                                    .player
                                                                    .setLoopMode(
                                                                        LoopMode
                                                                            .one);
                                                              } else {
                                                                controller
                                                                    .player
                                                                    .setLoopMode(
                                                                        LoopMode
                                                                            .off);
                                                              }
                                                            },
                                                            child:
                                                                loopMode ==
                                                                        LoopMode
                                                                            .one
                                                                    ? Stack(
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        children: [
                                                                          Icon(
                                                                            EvaIcons.repeat,
                                                                            size:
                                                                                10.w,
                                                                            color: loopMode == LoopMode.off
                                                                                ? Get.theme.primaryColor
                                                                                : kBlueColor,
                                                                          ),
                                                                          CircleAvatar(
                                                                            radius:
                                                                                2.w,
                                                                            backgroundColor:
                                                                                kBlueColor,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                '1',
                                                                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Icon(
                                                                        loopMode ==
                                                                                LoopMode.one
                                                                            ? EvaIcons.repeat
                                                                            : EvaIcons.repeat,
                                                                        size: 10
                                                                            .w,
                                                                        color: loopMode ==
                                                                                LoopMode.off
                                                                            ? Get.theme.primaryColor
                                                                            : kBlueColor,
                                                                      ),
                                                          );
                                                        } else {
                                                          return GestureDetector(
                                                            child: Icon(
                                                              EvaIcons.repeat,
                                                              size: 10.w,
                                                              color: Get.theme
                                                                  .primaryColor,
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
                                            stream: controller
                                                .player.durationStream,
                                            builder: (context,
                                                AsyncSnapshot dSnapshot) {
                                              Duration duration =
                                                  dSnapshot.data ??
                                                      Duration.zero;
                                              return StreamBuilder(
                                                  stream: controller
                                                      .player.positionStream,
                                                  builder: (context,
                                                      AsyncSnapshot pSnapshot) {
                                                    Duration position =
                                                        pSnapshot.data ??
                                                            Duration.zero;
                                                    return Column(
                                                      children: [
                                                        Slider(
                                                          thumbColor:
                                                              kBlueColor,
                                                          activeColor:
                                                              kBlueColor,
                                                          inactiveColor:
                                                              kTextGreyColor,
                                                          value: position
                                                              .inSeconds
                                                              .toDouble(),
                                                          onChanged: (value) {
                                                            controller.player
                                                                .seek(Duration(
                                                                    seconds: value
                                                                        .toInt()));
                                                          },
                                                          max: duration
                                                              .inSeconds
                                                              .toDouble(),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      7.w),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${position.inMinutes < 10 ? '0${position.inMinutes}' : position.inMinutes}:${position.inSeconds % 60 < 10 ? '0${position.inSeconds % 60}' : position.inSeconds % 60}',
                                                                style: TextStyle(
                                                                    color: Get
                                                                        .theme
                                                                        .primaryColor,
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Text(
                                                                '${duration.inMinutes < 10 ? '0${duration.inMinutes}' : duration.inMinutes}:${duration.inSeconds % 60 < 10 ? '0${duration.inSeconds % 60}' : duration.inSeconds % 60}',
                                                                style: TextStyle(
                                                                    color: Get
                                                                        .theme
                                                                        .primaryColor,
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            }),
                                        SizedBox(
                                          height: 4.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GetBuilder<SimilarController>(
                                builder: (sController) {
                              if (sController.similarSongs != null &&
                                  sController.similarSongs!.isNotEmpty) {
                                return SizedBox(
                                  height: 30.h,
                                  width: 100.w,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 2.h,
                                      right: 5.w,
                                      left: 5.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Recommended Tracks:',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 1.h,
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                          width: 90.w,
                                          child: ListView.builder(
                                            itemCount: sController
                                                .similarSongs!.length,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              Map similar = sController
                                                  .similarSongs![index];
                                              Map album =
                                                  similar['album'] ?? {};
                                              List images =
                                                  album['images'] ?? {};
                                              String image = images.isNotEmpty
                                                  ? images.first['url'] ?? ''
                                                  : '';
                                              String name =
                                                  similar['name'].toString();
                                              List artists =
                                                  similar['artists'] ?? [];
                                              String artist = artists
                                                  .first['name']
                                                  .toString();
                                              Map urls =
                                                  similar['external_urls'] ??
                                                      {};
                                              String url =
                                                  urls['spotify'].toString();
                                              // String playCount = similar['playcount'].toString();
                                              return GestureDetector(
                                                // onTap: () async {
                                                //   if (!await launchUrl(
                                                //       Uri.parse(url),
                                                //       mode: LaunchMode
                                                //           .inAppBrowserView)) {
                                                //     throw Exception(
                                                //         'Could not launch $url');
                                                //   }
                                                // },
                                                child: Container(
                                                  width: 18.h,
                                                  height: 18.h,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 2.w),
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    children: [
                                                      ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            image,
                                                            height: 18.h,
                                                            width: 18.h,
                                                            fit: BoxFit.fill,
                                                          )),
                                                      Container(
                                                        width: 18.h,
                                                        height: 6.h,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    2.w),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.black,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            similarText(name),
                                                            similarText(artist),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            }),
                          ],
                        ),
                      );
                    }),
              );
            });
      }),
    );
  }

  Text similarText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<bool> checkIsLiked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedSongs = prefs.getStringList('LikedSongs') ?? <String>[];
    return likedSongs.contains(id);
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
}
