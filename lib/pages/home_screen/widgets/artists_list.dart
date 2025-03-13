import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/pages/home_screen/widgets/list_detail.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';

class ArtistsList extends StatelessWidget {
  final List<ArtistModel> artists;
  const ArtistsList({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return artisCard(artist: artists[index]);
        },
      ),
    );
  }

  Widget artisCard({required ArtistModel artist}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: GestureDetector(
        onTap: () {
          Get.to(() => ListDetail(
                model: artist,
                mode: ListDetailMode.artist,
              ));
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artist.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 0.2.h,
              ),
              Text(
                '${artist.numberOfTracks} songs',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: kTextGreyColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
