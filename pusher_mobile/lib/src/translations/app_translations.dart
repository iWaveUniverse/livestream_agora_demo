import 'package:get/get.dart';

import '../../main.dart';
import '../utils/utils.dart';
import 'fr_fr_translation.dart';
import 'en_us_translations.dart';
import 'dart:ui';

import 'vi_vn_translation.dart';

//languages code
const String vietnamese = 'vi';
const String english = 'en';
const String french = 'fr';

List languagelist = [
  vietnamese,
  english,
  french,
];

List<Locale> supportedlocale = [
  const Locale(vietnamese, "VN"),
  const Locale(english, "US"),
  const Locale(french, 'FR'),
];

void setLocale(languageCode) {
  if (supportedlocale.any((e) => e.languageCode == languageCode)) {
    AppPrefs.instance.languageCode = languageCode;
    Get.locale =
        supportedlocale.firstWhere((e) => e.languageCode == languageCode);
    App.setLocale(Get.context!,
        supportedlocale.firstWhere((e) => e.languageCode == languageCode));
  }
}

Locale getLocale() {
  if (AppPrefs.instance.languageCode != null) {
    return _locale(AppPrefs.instance.languageCode!);
  }
  final Locale systemLocales = window.locale;
  return _locale(systemLocales.languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case vietnamese:
      return const Locale(vietnamese, 'VN');
    case french:
      return const Locale(french, 'FR');
    case english:
      return const Locale(english, 'US');
    default:
      return const Locale(english, 'US');
  }
}

abstract class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'vi_VN': viVN,
    'en_US': enUs,
    'fr_FR': frFR
  };
}
