import 'dart:math';
import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/controllers/app_controller.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/pages/home_screen/controller/home_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  final playerController = Get.put(PlayerController());
                  Random random = Random();
                  int index = random.nextInt(songs.length - 1);
                  playerController.player.setShuffleModeEnabled(true);
                  // playerController.initialPlay(path: song.data);
                  Get.to(() => PlaySongScreen());
                  playerController.sourceListGetter(list: songs, index: index);
                },
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: kBlueColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).iconTheme.color,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(
                width: 3.w,
              ),
              Text('t10'.tr),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  bool isDark = prefs.getBool('isDark') ?? true;
                  Get.bottomSheet(
                    GetBuilder<SongsListController>(builder: (slController) {
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
                              child: Text(
                                't14'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ),
                            sortCard(title: 't15'.tr, value: 0, isDark: isDark),
                            sortCard(title: 't16'.tr, value: 1, isDark: isDark),
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
                    quarterTurns: 3, child: Icon(EvaIcons.swapOutline)),
              ),
            ],
          ),
        ),
        GetBuilder<SongsListController>(builder: (slController) {
          return Expanded(
            child: FutureBuilder(
                future: songsListController.sortSongList(
                    songs, songsListController.sortValue),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    List<SongModel> list = snapshot.data;
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          SongModel song = list[index];
                          return songsCard(list, song, index);
                        });
                  } else {
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

  Widget sortCard(
      {required String title, required int value, required bool isDark}) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('SongSortValue', value);
        songsListController.setSortValue(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
        width: 90.w,
        decoration: BoxDecoration(
          color: songsListController.sortValue == value
              ? kBlueColor.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: songsListController.sortValue == value
                ? kBlueColor
                : (isDark ? Colors.white : kGreyColor),
          ),
        ),
      ),
    );
  }

  Widget songsCard(List<SongModel> songsList, SongModel song, int index) {
    return GestureDetector(
      onTap: () async {
        final playerController = Get.put(PlayerController());
        // playerController.initialPlay(path: song.data);
        await playerController.sourceListGetter(list: songsList, index: index);
        Get.to(() => PlaySongScreen());
      },
      child: Container(
        width: 90.w,
        height: 7.h,
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
        child: Row(
          children: [
            SizedBox(
              width: 6.h,
              height: 6.h,
              child: FutureBuilder(
                  future: controller.getSongImage(song.id),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      Uint8List? data = snapshot.data;
                      if (data != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            data,
                            width: 6.h,
                            height: 6.h,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/bd.png',
                            width: 6.h,
                            height: 6.h,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/gd.png',
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
                  Expanded(
                      child: Text(
                    song.title,
                    overflow: TextOverflow.ellipsis,
                  )),
                  Expanded(
                      child: Text(
                    song.artist ?? '<unknown>',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: kTextGreyColor),
                  )),
                ],
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
            Text(
              controller.durationGenerator(song.duration ?? 0),
              style: TextStyle(color: kTextGreyColor),
            ),
            SizedBox(
              width: 3.w,
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
                    value: 0,
                    child: Text('t13'.tr),
                  ),
                ],
                onChanged: (value) {
                  switch (value) {
                    case 0:
                      final homeController = Get.find<HomeController>();
                      kShowDialog(
                          verticalPadding: 30.h,
                          child: ListView.builder(
                            itemCount: homeController.playLists.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              PlaylistModel playlist =
                                  homeController.playLists[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    kAddToPlaylist(
                                        playlistId: playlist.id,
                                        audioId: song.id);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5.w, vertical: 1.5.h),
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
            ),
          ],
        ),
      ),
    );
  }
}
