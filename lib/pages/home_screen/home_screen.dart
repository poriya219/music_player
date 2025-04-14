import 'dart:async';
import 'dart:typed_data';

import 'package:MusicFlow/pages/find_screen/find_song_screen.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/controllers/app_controller.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/pages/home_screen/widgets/albums_list.dart';
import 'package:MusicFlow/pages/home_screen/widgets/artists_list.dart';
import 'package:MusicFlow/pages/home_screen/widgets/genres_list.dart';
import 'package:MusicFlow/pages/home_screen/widgets/list_detail.dart';
import 'package:MusicFlow/pages/home_screen/widgets/playlists.dart';
import 'package:MusicFlow/pages/home_screen/widgets/songs_list.dart';
import 'package:MusicFlow/pages/search_screen/search_screen.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_slider/widget_slider.dart';

import '../play_song_screen/play_song_screen.dart';
import 'controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());
  final playerController = Get.put(PlayerController());
  final appController = Get.put(AppController());

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final SliderController sliderController = SliderController();

  @override
  Widget build(BuildContext context) {
    final Color? textColor =
        (Get.theme.textTheme.bodyMedium ?? const TextStyle()).color;
    return GetBuilder<HomeController>(builder: (hController) {
      return Scaffold(
        key: _key,
        floatingActionButton: hController.selectedFilter == 'Playlist'
            ? FloatingActionButton(
                onPressed: () {
                  TextEditingController textEditingController =
                      TextEditingController();
                  kShowDialog(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('t4'.tr),
                        TextField(
                          controller: textEditingController,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('t5'.tr)),
                            TextButton(
                                onPressed: () async {
                                  try {
                                    final OnAudioQuery audioQuery =
                                        OnAudioQuery();
                                    bool status =
                                        await audioQuery.createPlaylist(
                                            textEditingController.text);
                                    if (status) {
                                      kShowToast('Playlist Created');
                                      Get.back();
                                      hController.resetPlaylists();
                                    } else {
                                      kShowToast('error');
                                      Get.back();
                                    }
                                  } catch (e) {
                                    kShowToast('error');
                                    Get.back();
                                  }
                                },
                                child: Text('t6'.tr)),
                          ],
                        ),
                      ],
                    ),
                    verticalPadding: 35.h,
                  );
                },
                backgroundColor: kBlueColor,
                child: const Icon(Icons.add),
              )
            : null,
        drawer: Drawer(
          child: SafeArea(
            child: GetBuilder<AppController>(builder: (aController) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    drawerButton(
                        title: 't9'.tr,
                        onTap: () async {
                          Get.back();
                          final prefs = await SharedPreferences.getInstance();
                          List<String> likedSongs =
                              prefs.getStringList('LikedSongs') ?? <String>[];
                          List<SongModel> songs = [];
                          for (SongModel song in hController.songs) {
                            QueryArtworkWidget a = QueryArtworkWidget(
                                artworkBorder: BorderRadius.circular(20),
                                artworkQuality: FilterQuality.high,
                                size: 5000,
                                quality: 100,
                                format: ArtworkFormat.JPEG,
                                id: song.id,
                                type: ArtworkType.AUDIO);
                            if (likedSongs.contains(a.id.toString())) {
                              songs.add(song);
                            }
                          }
                          Get.to(() => ListDetail(
                                model: songs,
                                mode: ListDetailMode.song,
                              ));
                        }),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       "t7".tr,
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.w500, fontSize: 16.sp),
                    //     ),
                    //     Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         TextButton(
                    //             onPressed: () async {
                    //               await Get.updateLocale(const Locale('fa'));
                    //               final prefs =
                    //                   await SharedPreferences.getInstance();
                    //               prefs.setString('locale', 'fa');
                    //               appController.setSelectedLocale('fa');
                    //             },
                    //             child: Text(
                    //               'فارسی',
                    //               style: TextStyle(
                    //                   color:
                    //                       appController.selectedLocale == 'fa'
                    //                           ? null
                    //                           : textColor),
                    //             )),
                    //         SizedBox(
                    //           height: 15,
                    //           width: 2,
                    //           child: VerticalDivider(
                    //             color: kGreyColor,
                    //             width: 15,
                    //             thickness: 2,
                    //           ),
                    //         ),
                    //         TextButton(
                    //             onPressed: () async {
                    //               await Get.updateLocale(const Locale('en'));
                    //               final prefs =
                    //                   await SharedPreferences.getInstance();
                    //               prefs.setString('locale', 'en');
                    //               appController.setSelectedLocale('en');
                    //             },
                    //             child: Text(
                    //               'English',
                    //               style: TextStyle(
                    //                   color:
                    //                       appController.selectedLocale == 'en'
                    //                           ? null
                    //                           : textColor),
                    //             )),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          't8'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16.sp),
                        ),
                        AnimatedToggleSwitch<int>.rolling(
                          current: appController.themeValue,
                          values: const [0, 1],
                          onChanged: (value) async {
                            final prefs = await SharedPreferences.getInstance();
                            appController.setThemeValue(value);
                            Timer(const Duration(milliseconds: 500), () {
                              Get.changeThemeMode(value == 0
                                  ? ThemeMode.light
                                  : ThemeMode.dark);
                              prefs.setBool(
                                  'isDark', value == 0 ? false : true);
                            });
                          },
                          iconBuilder: (int value, boolVale) {
                            switch (value) {
                              case 0:
                                return Icon(
                                  Icons.sunny,
                                  color: boolVale ? Colors.yellow : null,
                                );
                              case 1:
                                return Icon(
                                  EvaIcons.moon,
                                  color: boolVale ? Colors.cyan : null,
                                );
                              default:
                                return const SizedBox();
                            }
                          },
                          styleBuilder: (int value) {
                            switch (value) {
                              case 0:
                                return const ToggleStyle(
                                  indicatorColor: Colors.cyan,
                                );
                              case 1:
                                return const ToggleStyle(
                                  indicatorColor: Colors.indigo,
                                );
                              default:
                                return const ToggleStyle(
                                    indicatorColor: Colors.white);
                            }
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Text(
                        '${appController.appName} ${appController.version}',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w500),
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
                Get.to(() => FindSongScreen());
              },
              icon: Icon(
                EvaIcons.radioButtonOnOutline,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            IconButton(
                onPressed: () {
                  Get.to(() => SearchScreen());
                },
                icon: Icon(
                  EvaIcons.search,
                  color: Theme.of(context).iconTheme.color,
                )),
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
        bottomNavigationBar: StreamBuilder(
            stream: playerController.player.playingStream,
            builder: (context, AsyncSnapshot pSnapshot) {
              bool isPlaying = pSnapshot.data ?? false;
              return StreamBuilder(
                  stream: playerController.player.currentIndexStream,
                  builder: (context, AsyncSnapshot iSnapshot) {
                    int cIndex = iSnapshot.data ?? 0;
                    return StreamBuilder(
                        stream: playerController.player.sequenceStream,
                        builder: (context, AsyncSnapshot snapshot) {
                          List<IndexedAudioSource> list =
                              snapshot.data ?? <IndexedAudioSource>[];
                          if (snapshot.data == null) {
                            return const SizedBox();
                          }
                          QueryArtworkWidget artwork = list.isEmpty
                              ? const QueryArtworkWidget(
                                  id: 0, type: ArtworkType.AUDIO)
                              : QueryArtworkWidget(
                                  artworkBorder: BorderRadius.circular(20),
                                  artworkQuality: FilterQuality.high,
                                  size: 5000,
                                  quality: 100,
                                  format: ArtworkFormat.JPEG,
                                  id: int.parse(list[cIndex].tag.id),
                                  type: ArtworkType.AUDIO);
                          String songTitle =
                              list.isEmpty ? 'Unknown' : list[cIndex].tag.title;
                          String songArtist = list.isEmpty
                              ? 'Unknown'
                              : list[cIndex].tag.artist;
                          return WidgetSlider(
                              // itemCount: list.isEmpty ? 1 : list.length,
                              itemCount: 3,
                              proximity: 1,
                              fixedSize: 9.h,
                              controller: appController.sliderController,
                              onMove: (i) {
                                if (!appController.isSeeking) {
                                  appController.seekSliderController(1);
                                  if (i == 2) {
                                    playerController.player.seekToNext();
                                  } else if (i == 0) {
                                    playerController.player.seekToPrevious();
                                  }
                                }
                              },
                              transformCurve: const ElasticOutCurve(),
                              sizeDistinction: 0.99,
                              itemBuilder: (context, index, activeIndex) {
                                // appController.seekSliderController(cIndex);
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => PlaySongScreen());
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF7B7C7D),
                                          offset: Offset(5, -76),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
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
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    songTitle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    songArtist,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: kTextGreyColor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 0.5.h,
                                                  ),
                                                ],
                                              )),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        StreamBuilder(
                                                            stream: playerController
                                                                .player
                                                                .durationStream,
                                                            builder: (context,
                                                                AsyncSnapshot
                                                                    dSnapshot) {
                                                              return StreamBuilder(
                                                                  stream: playerController
                                                                      .player
                                                                      .positionStream,
                                                                  builder: (context,
                                                                      AsyncSnapshot
                                                                          pSnapshot) {
                                                                    if (pSnapshot
                                                                            .hasData &&
                                                                        dSnapshot
                                                                            .hasData) {
                                                                      Duration
                                                                          duration =
                                                                          dSnapshot.data ??
                                                                              const Duration(seconds: 1);
                                                                      Duration
                                                                          position =
                                                                          pSnapshot.data ??
                                                                              Duration.zero;
                                                                      return CircularProgressIndicator(
                                                                        value: position.inSeconds /
                                                                            duration.inSeconds,
                                                                        color:
                                                                            kBlueColor,
                                                                        strokeWidth:
                                                                            3,
                                                                        backgroundColor:
                                                                            const Color(0xFFCCCCCC),
                                                                      );
                                                                    } else {
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
                                                                : Icons
                                                                    .play_arrow,
                                                            color: Theme.of(
                                                                    context)
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
                                                  ],
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
                                            child: controller
                                                    .isGrantedPermission
                                                ? FutureBuilder(
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
                                                    })
                                                : CircleAvatar(
                                                    radius: 7.w,
                                                    foregroundColor: kBlueColor,
                                                    backgroundColor: kBlueColor,
                                                  )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        });
                  });
            }),
        body: SafeArea(
          child: Column(
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
                child: WidgetSlider(
                  itemCount: 5,
                  proximity: 1,
                  fixedSize: 100.h,
                  transformCurve: const ElasticOutCurve(),
                  sizeDistinction: 0.99,
                  controller: sliderController,
                  onMove: (i) {
                    switch (i) {
                      case 0:
                        controller.setSelectedFilter('Song');
                        break;
                      case 1:
                        controller.setSelectedFilter('Playlist');
                        break;
                      case 2:
                        controller.setSelectedFilter('Artist');
                        break;
                      case 3:
                        controller.setSelectedFilter('Album');
                        break;
                      case 4:
                        controller.setSelectedFilter('Genre');
                        break;
                    }
                  },
                  itemBuilder: (context, index, activeIndex) {
                    return controller.selectedFilter == 'Song'
                        ? SongsList(songs: controller.songs)
                        : controller.selectedFilter == 'Playlist'
                            ? Playlists(playlists: controller.playLists)
                            : controller.selectedFilter == 'Artist'
                                ? ArtistsList(artists: controller.artists)
                                : controller.selectedFilter == 'Album'
                                    ? AlbumsList(albums: controller.albums)
                                    : controller.selectedFilter == 'Genre'
                                        ? GenresList(genres: controller.genres)
                                        : SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget drawerButton({required String title, required Function onTap}) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        width: 65.w,
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
        ),
      ),
    );
  }

  int sliderIndexGetter(String title) {
    switch (title) {
      case 'Song':
        return 0;
      case 'Playlist':
        return 1;
      case 'Artist':
        return 2;
      case 'Album':
        return 3;
      case 'Genre':
        return 4;
      default:
        return 0;
    }
  }

  Widget filterContainer({required String title}) {
    return GestureDetector(
        onTap: () {
          controller.setSelectedFilter(title);
          sliderController.moveTo!.call(sliderIndexGetter(title));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: controller.selectedFilter == title
                ? kBlueColor
                : const Color(0xFF7b7c7d),
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
