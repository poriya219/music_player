import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controllers/app_controller.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';

class SongsList extends StatelessWidget {
  final List<SongModel> songs;
  SongsList({super.key, required this.songs});

  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: songs.length,
        itemBuilder: (context,index){
          SongModel song = songs[index];
          return songsCard(song);
        });
  }

  Widget songsCard(SongModel song){
    return GestureDetector(
      onTap: (){
        final playerController = Get.put(PlayerController());
        if(playerController.isPlaying){}
        else{
          playerController.initialPlay(path: song.data);
        }
      },
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
                  Expanded(child: Text(song.title,overflow: TextOverflow.ellipsis,style: const TextStyle(color: Colors.white),)),
                  Expanded(child: Text(song.artist ?? '<unknown>',overflow: TextOverflow.ellipsis,style: TextStyle(color: kTextGreyColor),)),
                ],
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
            Text(controller.durationGenerator(song.duration ?? 0),style: TextStyle(color: kTextGreyColor),),
          ],
        ),
      ),
    );
  }
}
