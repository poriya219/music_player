import 'dart:convert';

import 'package:flutter/services.dart';

class Fa {
  Map<String, String> translations = {};

  createTranslations() async {
    String faFile = await rootBundle.loadString('assets/i18n/fa.json');
    Map enData = jsonDecode(faFile);
    enData.forEach((key, value) {
      translations[key] = value;
    });
    return translations;
  }
}
