import 'package:MusicFlow/controllers/similar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SimilarTracks extends StatelessWidget {
  const SimilarTracks({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimilarController>(builder: (sController) {
      if (sController.similarSongs != null &&
          sController.similarSongs!.isNotEmpty) {
        return SizedBox(
          height: 30.h,
          width: 100.w,
          child: Padding(
            padding: EdgeInsets.only(
              top: 2.h,
              right: 5.w,
              left: 5.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  't17'.tr,
                  style: TextStyle(
                    color: Theme.of(context).iconTheme.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                SizedBox(
                  height: 20.h,
                  width: 90.w,
                  child: ListView.builder(
                    itemCount: sController.similarSongs!.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Map similar = sController.similarSongs![index];
                      Map album = similar['album'] ?? {};
                      List images = album['images'] ?? {};
                      String image =
                          images.isNotEmpty ? images.first['url'] ?? '' : '';
                      String name = similar['name'].toString();
                      List artists = similar['artists'] ?? [];
                      String artist = artists.first['name'].toString();
                      Map urls = similar['external_urls'] ?? {};
                      String url = urls['spotify'].toString();
                      // String playCount = similar['playcount'].toString();
                      return GestureDetector(
                        // onTap: () async {
                        //   if (!await launchUrl(
                        //       Uri.parse(url),
                        //       mode: LaunchMode
                        //           .inAppBrowserView)) {
                        //     throw Exception(
                        //         'Could not launch $url');
                        //   }
                        // },
                        child: Container(
                          width: 18.h,
                          height: 18.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    image,
                                    height: 18.h,
                                    width: 18.h,
                                    fit: BoxFit.fill,
                                  )),
                              Container(
                                width: 18.h,
                                height: 6.h,
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    similarText(name),
                                    similarText(artist),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}

Text similarText(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
