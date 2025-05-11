import 'package:MusicFlow/controllers/ad_controller.dart';
import 'package:MusicFlow/controllers/app_controller.dart';
import 'package:MusicFlow/controllers/equalizer_ui_controller.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:get/get.dart';
import 'package:MusicFlow/pages/home_screen/controller/home_controller.dart';

import 'controllers/similar_controller.dart';

class Initializer extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(SimilarController());
    Get.put(AdController());
    Get.put(AppController());
    Get.put(PlayerController());
    Get.put(EqualizerUiController());
  }
}
