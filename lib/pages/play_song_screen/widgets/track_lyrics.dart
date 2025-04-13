import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/controllers/lyrics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TrackLyrics extends StatelessWidget {
  final String songTitle;
  final String songArtist;
  TrackLyrics({super.key, required this.songArtist, required this.songTitle});
  final lyricsController = Get.put(LyricsController());

  @override
  Widget build(BuildContext context) {
    lyricsController.getLyrics(title: songTitle, artist: songArtist);
    return GetBuilder<LyricsController>(builder: (lController) {
      return lyricsController.lyricsString != null
          ? Container(
              decoration: BoxDecoration(
                color: kBlueColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 90.w,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                          itemCount: lyricsController.lyricsString == null
                              ? 0
                              : lyricsController.lyricsString!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Text(
                                lyricsController.lyricsString![index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).iconTheme.color,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500),
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
            )
          : const SizedBox();
    });
  }
}
