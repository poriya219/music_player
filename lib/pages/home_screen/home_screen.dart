
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/constans.dart';
import 'package:music_player/pages/home_screen/widgets/songs_list.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackBlackColor,
      appBar: AppBar(
        backgroundColor: kBackBlackColor,
        surfaceTintColor: kBackBlackColor,
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ))
        ],
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
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
                child: controller.selectedFilter == 'Song'
                    ? SongsList(songs: controller.songs)
                    : SizedBox(),
              ),
              Container(
                color: kBackBlackColor.withOpacity(1.0),
                height: 8.h,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      color: kBackBlackColor,
                      width: 100.w,
                      height: 6.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22.w,
                          ),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Another Love',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              ),
                              Text('Tom Odell',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: kTextGreyColor,
                                ),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                            ],
                          )),
                          GestureDetector(
                            onTap: (){},
                            child: Icon(Icons.play_arrow,color: Colors.white,size: 8.w,),
                          ),
                          SizedBox(
                            width: 7.w,
                          ),
                          GestureDetector(
                            onTap: (){},
                            child: Icon(Icons.skip_next,color: kGreyColor,size: 7.w,),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        left: 4.w,
                        bottom: 1.h,
                        child: CircleAvatar(
                          radius: 7.w,
                          foregroundColor: kBlueColor,
                          backgroundColor: kBlueColor,
                        )),
                  ],
                ),
              ),
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
            color: controller.selectedFilter == title ? kBlueColor : kGreyColor,
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
