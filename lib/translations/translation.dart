import 'package:get/get.dart';
import 'languages/en.dart';
import 'languages/fa.dart';

class Translator extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {};

  static Future<void> initLanguages() async {
    final keys = await readJson();
    Get.clearTranslations();
    Get.addTranslations(keys);
  }

  static Future<Map<String, Map<String, String>>> readJson() async {
    Map<String, String> en = await En().createTranslations();
    Map<String, String> fa = await Fa().createTranslations();
    return {
      'en': en,
      'fa': fa,
    };
  }
}
