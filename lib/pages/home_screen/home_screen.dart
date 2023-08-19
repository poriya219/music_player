import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/constans.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackBlackColor,
      body: SafeArea(
        child: GetBuilder<HomeController>(builder: (hController){
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
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: controller.songs.length,
                    itemBuilder: (context,index){
                      SongModel song = controller.songs[index];
                      return songsCard(song);
                    }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget filterContainer({required String title}){
    return GestureDetector(
        onTap: (){
          controller.setSelectedFilter(title);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 1.h),
          margin: EdgeInsets.symmetric(horizontal: 2.w,vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: controller.selectedFilter == title ? kBlueColor : kGreyColor,
          ),
          child: Center(
            child: Text(title,
            style: const TextStyle(
              color: Colors.white,
            ),
            ),
          ),
        ));
  }

  Widget songsCard(SongModel song){
    return GestureDetector(
      onTap: (){},
      child: Container(
        width: 90.w,
        height: 7.h,
        margin: EdgeInsets.symmetric(vertical: 1.h,horizontal: 5.w),
        child: Row(
          children: [
            SizedBox(
              width: 6.h,
              height: 6.h,
              child: FutureBuilder(future: controller.getSongImage(song.id), builder: (context, AsyncSnapshot snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                  Uint8List? data = snapshot.data;
                  if(data != null){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(data,
                      width: 6.h,
                        height: 6.h,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  else{
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset('assets/images/bd.png',
                        width: 6.h,
                        height: 6.h,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                }
                else{
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/images/gd.png',
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
                  Expanded(child: Text(song.title,overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white),)),
                  Expanded(child: Text(song.artist ?? '<unknown>',overflow: TextOverflow.ellipsis,style: TextStyle(color: kTextGreyColor),)),
                ],
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
            Text(durationGenerator(song.duration ?? 0),style: TextStyle(color: kTextGreyColor),),
          ],
        ),
      ),
    );
  }

  String durationGenerator(int duration){
    int allSeconds = duration ~/ 1000;
    int min = allSeconds ~/ 60;
    int second = allSeconds % 60;
    return '${min < 10 ? '0$min' : min}:${second < 10 ? '0$second' : second}';
  }
}
