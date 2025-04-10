import 'package:adivery/adivery.dart';
import 'package:get/get.dart';

class AdController extends GetxController {
  @override
  void onInit() {
    AdiveryPlugin.initialize("51321c7d-bd61-4a80-8f93-fd343cb9574d");
    showInterstitial();
    super.onInit();
  }

  showInterstitial() {
    const String placementId = "afeb3184-86ad-44c8-b720-24d03f984719";
    AdiveryPlugin.prepareInterstitialAd(placementId);
    show(placementId, 0);
  }

  show(placementId, int retry) {
    AdiveryPlugin.isLoaded(placementId)
        .then((isLoaded) => showPlacement(isLoaded, placementId, retry));
  }

  void showPlacement(bool? isLoaded, String placementId, int retry) {
    if (isLoaded == true) {
      AdiveryPlugin.show(placementId);
    } else {
      if (retry < 4) {
        show(placementId, retry + 1);
      }
    }
  }
}
