import 'dart:convert';

import 'package:flutter/services.dart';

class En {
  Map<String, String> translations = {};

  createTranslations() async {
    String enFile = await rootBundle.loadString('assets/i18n/en.json');
    Map enData = jsonDecode(enFile);
    enData.forEach((key, value) {
      translations[key] = value;
    });
    return translations;
  }
}
