import 'package:get/get.dart';
import 'package:music_player/pages/home_screen/controller/home_controller.dart';

import 'controllers/similar_controller.dart';

class Initializer extends Bindings {

  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(SimilarController());
  }
}