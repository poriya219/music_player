import 'package:MusicFlow/constans.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:get/get.dart';

class FindSongController extends GetxController {
  ACRCloudResponseMusicItem? music;
  setMusic(ACRCloudResponseMusicItem? value) {
    music = value;
    update();
  }

  bool isActive = false;
  setIsActive(bool value) {
    isActive = value;
    update();
  }

  findMusic() async {
    initService();
    setMusic(null);
    final session = ACRCloud.startSession();
    if (isActive == true) {
      session.cancel;
    }

    setIsActive(isActive ? false : true);

    final result = await session.result;

    if (result == null) {
      // Cancelled.
      setIsActive(false);
      return;
    } else if (result.metadata == null) {
      setIsActive(false);
      kShowToast('No result.');
      return;
    }
    setMusic(result.metadata!.music.first);
    setIsActive(false);
  }

  initService() {
    const String apik = '643bbc149794d9a140fc7438b4699dc7';
    const String apis = 'S3Q7dYcR0VzVYFVxlGZFuWTYCiemVo0uXyXLnWKf';
    const String host = 'identify-eu-west-1.acrcloud.com';
    ACRCloud.setUp(const ACRCloudConfig(apik, apis, host));
  }
}
