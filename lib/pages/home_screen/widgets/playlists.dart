import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';
import '../../../controllers/app_controller.dart';
import '../controller/home_controller.dart';
import 'list_detail.dart';

class Playlists extends StatelessWidget {
  final List playlists;
  Playlists({super.key, required this.playlists});

  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 9 / 10,
        ),
        itemCount: playlists.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => playlistCard(
          playlist: playlists[index],
        ),
      ),
    );
  }

  Widget playlistCard({required Map playlist}) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ListDetail(
              model: playlist,
              mode: ListDetailMode.playlist,
            ));
      },
      onLongPress: () {
        // kShowDialog(
        //     verticalPadding: 30.h,
        //     child: ListView(
        //       shrinkWrap: true,
        //       children: [
        //         InkWell(
        //           onTap: () async {
        //             final OnAudioQuery audioQuery = OnAudioQuery();
        //             await audioQuery.removePlaylist(playlist.id);
        //             Get.back();
        //             kShowToast('Playlist Removed');
        //             final controller = Get.find<HomeController>();
        //             controller.resetPlaylists();
        //           },
        //           child: Padding(
        //             padding:
        //                 EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        //             child: const Text(
        //               'Remove Playlist',
        //             ),
        //           ),
        //         )
        //       ],
        //     ));
      },
      child: Column(
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: FutureBuilder(
                future: controller.getPlaylistImage(0),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    Uint8List? data = snapshot.data;
                    if (data != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          data,
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/bd.png',
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/gd.png',
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                }),
          ),
          SizedBox(
            height: 0.5.h,
          ),
          SizedBox(
            width: 40.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
