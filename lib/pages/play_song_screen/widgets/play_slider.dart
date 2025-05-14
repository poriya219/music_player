import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/controllers/audio_service_singleton.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlaySlider extends StatelessWidget {
  PlaySlider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AudioServiceSingleton().handler.mediaItem,
        builder: (context, AsyncSnapshot dSnapshot) {
          final MediaItem? mediaItem = dSnapshot.data;
          Duration duration = mediaItem == null
              ? Duration.zero
              : mediaItem.duration ?? Duration.zero;
          print('duration: ${duration.inSeconds}');
          return StreamBuilder(
              stream: AudioServiceSingleton().handler.customState,
              builder: (context, AsyncSnapshot pSnapshot) {
                final posMs = pSnapshot.data?['position'] ?? 0;
                final Duration position = Duration(milliseconds: posMs);
                return Column(
                  children: [
                    Slider(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
                      thumbColor: kBlueColor,
                      activeColor: kBlueColor,
                      inactiveColor: kTextGreyColor,
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) {
                        AudioServiceSingleton()
                            .handler
                            .seek(Duration(seconds: value.toInt()));
                      },
                      max: duration.inSeconds.toDouble(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${position.inMinutes < 10 ? '0${position.inMinutes}' : position.inMinutes}:${position.inSeconds % 60 < 10 ? '0${position.inSeconds % 60}' : position.inSeconds % 60}',
                          style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${duration.inMinutes < 10 ? '0${duration.inMinutes}' : duration.inMinutes}:${duration.inSeconds % 60 < 10 ? '0${duration.inSeconds % 60}' : duration.inSeconds % 60}',
                          style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                );
              });
        });
  }
}
