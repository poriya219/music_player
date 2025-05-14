import 'dart:io';

import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/controllers/audio_service_singleton.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/play_buttons.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/similar_tracks.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/track_lyrics.dart';
import 'package:adivery/adivery_ads.dart';
import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/controllers/similar_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlaySongScreen extends StatelessWidget {
  PlaySongScreen({super.key});

  final controller = Get.put(PlayerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PlayerController>(builder: (pController) {
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
              stream: AudioServiceSingleton().handler.mediaItem,
              builder: (context, AsyncSnapshot snapshot) {
                final MediaItem? mediaItem = snapshot.data;
                String songTitle = snapshot.hasData
                    ? (mediaItem != null ? mediaItem.title : 'Unknown')
                    : 'Unknown';
                String songArtist = snapshot.hasData
                    ? (mediaItem != null
                        ? mediaItem!.artist ?? 'Unknown'
                        : 'Unknown')
                    : 'Unknown';
                final similarController = Get.find<SimilarController>();
                similarController.getSimilarTracks(
                    title: songTitle, artist: songArtist);
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: kBackIcon(),
                            ),
                            SizedBox(
                              width: 70.w,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    songTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    songArtist,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 52.h,
                                child: Center(
                                  child: SizedBox(
                                    width: 85.w,
                                    height: 85.w,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(40),
                                            topLeft: Radius.circular(40),
                                            topRight: Radius.circular(40),
                                          ),
                                          child: mediaItem == null
                                              ? Image.asset(
                                                  'assets/images/gd.png',
                                                  height: 80.h,
                                                  fit: BoxFit.fitHeight,
                                                )
                                              : Image.file(
                                                  File(mediaItem.artUri!.path),
                                                  height: 80.h,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                        )),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: PlayButtons(
                                  songId: mediaItem != null
                                      ? mediaItem.id
                                      : 'Unknown',
                                  songTitle: songTitle,
                                ),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              TrackLyrics(
                                  songArtist: songArtist, songTitle: songTitle),
                              const SimilarTracks(),
                              // const BannerAd(
                              //     "9472ec74-8b8f-4e38-8913-9315b85da184",
                              //     BannerAdSize.BANNER),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        );
      }),
    );
  }
}
