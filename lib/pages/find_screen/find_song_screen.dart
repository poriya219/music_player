import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/pages/find_screen/controller/find_song_controller.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FindSongScreen extends StatelessWidget {
  FindSongScreen({super.key});
  final controller = Get.put(FindSongController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GetBuilder<FindSongController>(builder: (fsController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(EvaIcons.arrowIosBack),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 35.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          't1'.tr,
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        if (controller.music == null &&
                            controller.isActive == false) ...{
                          Text(
                            't2'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        },
                        if (controller.isActive == true) ...[
                          Text(
                            't3'.tr,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                        if (controller.music != null) ...[
                          Text(
                            '${controller.music!.title} - ${controller.music!.artists.first.name}\n',
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                        onTap: () async {
                          controller.findMusic();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kBlueColor,
                                kGreyColor,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: controller.isActive == false
                              ? const Icon(
                                  Icons.music_note_outlined,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : LoadingAnimationWidget.progressiveDots(
                                  color: Colors.white, size: 50),
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      })),
    );
  }
}
