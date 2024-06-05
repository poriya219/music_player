import 'dart:async';
import 'dart:typed_data';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/constans.dart';
import 'package:music_player/controllers/app_controller.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:music_player/pages/home_screen/widgets/albums_list.dart';
import 'package:music_player/pages/home_screen/widgets/artists_list.dart';
import 'package:music_player/pages/home_screen/widgets/genres_list.dart';
import 'package:music_player/pages/home_screen/widgets/playlists.dart';
import 'package:music_player/pages/home_screen/widgets/songs_list.dart';
import 'package:music_player/pages/search_screen/search_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../play_song_screen/play_song_screen.dart';
import 'controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());
  final playerController = Get.put(PlayerController());
  final appController = Get.put(AppController());

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: SafeArea(
          child: GetBuilder<AppController>(builder: (aController){
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 2.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Theme mode:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp
                      ),
                      ),
                      AnimatedToggleSwitch<int>.rolling(
                        current: appController.themeValue,
                        values: const [0, 1],
                        onChanged: (value) async{
                          final prefs = await SharedPreferences.getInstance();
                          appController.setThemeValue(value);
                          Timer(const Duration(milliseconds: 500), () {
                            Get.changeThemeMode(
                                value == 0 ? ThemeMode.light : ThemeMode.dark);
                            prefs.setBool('isDark', value == 0 ? false : true);
                          });
                        },
                        iconBuilder: (int value,size,boolVale){
                          switch(value){
                            case 0:
                              return Icon(Icons.sunny,
                              color: boolVale ? Colors.yellow : null,
                              );
                            case 1:
                              return Icon(EvaIcons.moon,
                                color: boolVale ? Colors.cyan : null,
                              );
                            default:
                              return const SizedBox();
                          }
                        },
                        colorBuilder: (int value){
                          switch(value){
                            case 0:
                              return Colors.cyan;
                            case 1:
                              return Colors.indigo;
                            default:
                              return Colors.white;
                          }
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('${appController.appName} ${appController.version}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500
                  ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Get.to(()=> SearchScreen());
              },
              icon: Icon(
                EvaIcons.search,
                color: Theme.of(context).iconTheme.color,
              ))
        ],
        leading: IconButton(
            onPressed: () {
              _key.currentState!.openDrawer();
            },
            icon: Icon(
              EvaIcons.menu,
              color: Theme.of(context).iconTheme.color,
            )),
      ),
      body: SafeArea(
        child: GetBuilder<HomeController>(builder: (hController) {
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filterContainer(title: 'Song'),
                    filterContainer(title: 'Playlist'),
                    filterContainer(title: 'Artist'),
                    filterContainer(title: 'Album'),
                    filterContainer(title: 'Genre'),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    controller.selectedFilter == 'Song'
                        ? SongsList(songs: controller.songs)
                    : controller.selectedFilter == 'Playlist'
                        ? Playlists(playlists: controller.playLists)
                        : controller.selectedFilter == 'Artist'
                        ? ArtistsList(artists: controller.artists)
                        : controller.selectedFilter == 'Album'
                        ? AlbumsList(albums: controller.albums)
                        : controller.selectedFilter == 'Genre'
                        ? GenresList(genres: controller.genres)
                        : SizedBox()
                  ],
                ),
              ),
              StreamBuilder(
                  stream: playerController.player.playingStream,
                  builder: (context, AsyncSnapshot pSnapshot) {
                    if (pSnapshot.hasData) {
                      bool isPlaying = pSnapshot.data ?? false;
                      return StreamBuilder(
                          stream: playerController.player.currentIndexStream,
                          builder: (context, AsyncSnapshot iSnapshot) {
                            if (iSnapshot.hasData) {
                              int cIndex = iSnapshot.data ?? 0;
                              return StreamBuilder(
                                  stream:
                                      playerController.player.sequenceStream,
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      List<IndexedAudioSource> list =
                                          snapshot.data ??
                                              <IndexedAudioSource>[];
                                      QueryArtworkWidget artwork =
                                          list[cIndex].tag.artwork;
                                      String songTitle = list[cIndex].tag.title;
                                      String songArtist =
                                          list[cIndex].tag.artist;
                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(() => PlaySongScreen());
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 9.h,
                                          child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Container(
                                                width: 100.w,
                                                height: 7.h,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 22.w,
                                                    ),
                                                    Expanded(
                                                        child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          songTitle,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          songArtist,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                kTextGreyColor,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 0.5.h,
                                                        ),
                                                      ],
                                                    )),
                                                    Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        StreamBuilder(stream: playerController.player.durationStream, builder: (context,AsyncSnapshot dSnapshot){
                                                          return StreamBuilder(stream: playerController.player.positionStream, builder: (context,AsyncSnapshot pSnapshot){
                                                            if(pSnapshot.hasData && dSnapshot.hasData){
                                                              Duration duration = dSnapshot.data ?? const Duration(seconds: 1);
                                                              Duration position = pSnapshot.data ?? Duration.zero;
                                                              return CircularProgressIndicator(
                                                                value: position.inSeconds / duration.inSeconds,
                                                                color: kBlueColor,
                                                                strokeWidth: 3,
                                                                backgroundColor: const Color(0xFFCCCCCC),
                                                              );
                                                            }
                                                            else{
                                                              return const SizedBox();
                                                            }
                                                          });
                                                        }),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (isPlaying) {
                                                              playerController
                                                                  .player
                                                                  .stop();
                                                            } else {
                                                              playerController
                                                                  .player
                                                                  .play();
                                                            }
                                                          },
                                                          child: Icon(
                                                            isPlaying
                                                                ? Icons.pause
                                                                : Icons.play_arrow,
                                                            color: Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                            size: 8.w,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 7.w,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        playerController.player
                                                            .seekToNext();
                                                      },
                                                      child: Icon(
                                                        EvaIcons.skipForward,
                                                        color: kTextGreyColor,
                                                        size: 7.w,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5.w,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                  left: 4.w,
                                                  bottom: 2.h,
                                                  child: FutureBuilder(
                                                      future: appController
                                                          .getSongImage(
                                                              artwork.id),
                                                      builder: (context,
                                                          AsyncSnapshot
                                                              fSnapshot) {
                                                        if (fSnapshot.hasData &&
                                                            fSnapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .done) {
                                                          Uint8List data =
                                                              fSnapshot.data;
                                                          return CircleAvatar(
                                                              radius: 7.w,
                                                              foregroundColor:
                                                                  kBlueColor,
                                                              backgroundColor:
                                                                  kBlueColor,
                                                              foregroundImage:
                                                                  MemoryImage(
                                                                      data));
                                                        } else {
                                                          return SizedBox();
                                                        }
                                                      })),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  });
                            } else {
                              return const SizedBox();
                            }
                          });
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          );
        }),
      ),
    );
  }

  Widget filterContainer({required String title}) {
    return GestureDetector(
        onTap: () {
          controller.setSelectedFilter(title);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: controller.selectedFilter == title
                ? kBlueColor
                : Get.theme.primaryColor,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: kSecondColor,
              ),
            ),
          ),
        ));
  }
}
