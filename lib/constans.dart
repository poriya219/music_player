import 'package:MusicFlow/controllers/app_controller.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/pages/home_screen/controller/home_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

Color kBackBlackColor = const Color(0xFF191a1d);
// Color kBlueColor = const Color(0xFF3a62f1);
Color kGreyColor = const Color(0xFF262626);
Color kTextGreyColor = const Color(0xFF434446);
Color kSecondColor = Colors.white;
Color kBlueColor = const Color(0xFF4da5e0);
const Color kLightPurpleColor = Color(0xFFa7a3ae);

kShowToast(String title) {
  Fluttertoast.showToast(
      msg: title,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: kBlueColor,
      textColor: Colors.white,
      fontSize: 16.0);
}

kShowDialog({required Widget child, required double verticalPadding}) {
  Get.dialog(
    Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 5.w),
      child: Material(
        child: Container(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h), child: child),
        ),
      ),
    ),
  );
}

kAddToPlaylist({required int playlistId, required int audioId}) async {
  final OnAudioQuery audioQuery = OnAudioQuery();
  await audioQuery.addToPlaylist(playlistId, audioId);
  Get.back();
  kShowToast('Song added to playlist');
  final controller = Get.find<HomeController>();
  controller.resetPlaylists();
}

bool kIsFa(String text) {
  final persianRegex = RegExp(r'[\u0600-\u06FF]');
  return persianRegex.hasMatch(text);
}

Widget kBackIcon() {
  final appController = Get.put(AppController());
  return Icon(
    appController.selectedLocale == 'en'
        ? EvaIcons.arrowIosBack
        : EvaIcons.arrowIosForward,
    color: Theme.of(Get.context!).primaryColor,
    size: 7.w,
  );
}
