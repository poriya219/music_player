import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/pages/home_screen/widgets/list_detail.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';

class GenresList extends StatelessWidget {
  final List<GenreModel> genres;
  const GenresList({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          return genreCard(genre: genres[index]);
        },
      ),
    );
  }

  Widget genreCard({required GenreModel genre}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: GestureDetector(
        onTap: () {
          Get.to(() => ListDetail(
                model: genre,
                mode: ListDetailMode.genre,
              ));
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                genre.genre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 0.2.h,
              ),
              Text(
                '${genre.numOfSongs} songs',
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
