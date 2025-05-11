import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/play_buttons.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/play_slider.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/similar_tracks.dart';
import 'package:MusicFlow/pages/play_song_screen/widgets/track_lyrics.dart';
import 'package:adivery/adivery_ads.dart';
import 'package:animations/animations.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:MusicFlow/controllers/lyrics_controller.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/controllers/similar_controller.dart';
import 'package:MusicFlow/pages/play_song_screen/show_song_controls.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:widget_slider/widget_slider.dart';

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
                              artworkBorder: const BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40)),
                              artworkQuality: FilterQuality.high,
                              nullArtworkWidget: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(40),
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40)),
                                child: Image.asset(
                                  'assets/images/gd.png',
                                  height: 80.h,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              size: 5000,
                              quality: 100,
                              format: ArtworkFormat.JPEG,
                              id: int.parse(list[cIndex].tag.id),
                              type: ArtworkType.AUDIO)
                          : const QueryArtworkWidget(
                              artworkBorder: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40)),
                              id: 0,
                              type: ArtworkType.AUDIO);
                      String songTitle = iSnapshot.hasData
                          ? list[cIndex].tag.title
                          : 'Unknown';
                      String songArtist = iSnapshot.hasData
                          ? list[cIndex].tag.artist
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              child: artwork),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.h,
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: PlayButtons(
                                        player: controller.player,
                                        artwork: artwork,
                                        songTitle: songTitle,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    TrackLyrics(
                                        songArtist: songArtist,
                                        songTitle: songTitle),
                                    const SimilarTracks(),
                                    const BannerAd(
                                        "9472ec74-8b8f-4e38-8913-9315b85da184",
                                        BannerAdSize.BANNER),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              );
            });
      }),
    );
  }
}
