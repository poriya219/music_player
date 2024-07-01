import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';
import '../../../controllers/app_controller.dart';
import 'list_detail.dart';

class AlbumsList extends StatelessWidget {
  final List<AlbumModel> albums;
  AlbumsList({super.key, required this.albums});

  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: ListView.builder(
        itemCount: albums.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          return albumCard(album: albums[index]);
        },),
    );
  }

  Widget albumCard({required AlbumModel album}){
    return Padding(padding: EdgeInsets.symmetric(vertical: 1.h),
    child: GestureDetector(
      onTap: (){
        Get.to(()=> ListDetail(model: album,mode: ListDetailMode.album,));
      },
      child: Row(
        children: [
          SizedBox(
            width: 6.7.h,
            height: 6.7.h,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 0.7.h),
                  width: 6.h,
                  height: 6.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 6.h,
                  height: 6.h,
                  child: FutureBuilder(future: controller.getAlbumImage(album.id), builder: (context, AsyncSnapshot snapshot){
                    if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                      Uint8List? data = snapshot.data;
                      if(data != null){
                        return Image.memory(data,
                          width: 6.h,
                          height: 6.h,
                          fit: BoxFit.cover,
                        );
                      }
                      else{
                        return Image.asset('assets/images/bd.png',
                          width: 6.h,
                          height: 6.h,
                          fit: BoxFit.cover,
                        );
                      }
                    }
                    else{
                      return Image.asset('assets/images/gd.png',
                        width: 6.h,
                        height: 6.h,
                        fit: BoxFit.cover,
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 2.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(album.album,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 0.2.h,
              ),
              Text('${album.artist}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: kTextGreyColor),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
