import 'package:MusicFlow/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlaySlider extends StatelessWidget {
  final AudioPlayer player;
  const PlaySlider({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: player.durationStream,
        builder: (context, AsyncSnapshot dSnapshot) {
          Duration duration = dSnapshot.data ?? Duration.zero;
          return StreamBuilder(
              stream: player.positionStream,
              builder: (context, AsyncSnapshot pSnapshot) {
                Duration position = pSnapshot.data ?? Duration.zero;
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
                        player.seek(Duration(seconds: value.toInt()));
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
