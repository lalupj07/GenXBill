import 'package:flutter/material.dart';

class LocaleUtils {
  static Locale getLocaleFromLanguage(String language) {
    switch (language) {
      case 'Hindi':
        return const Locale('hi');
      case 'Spanish':
        return const Locale('es');
      case 'French':
        return const Locale('fr');
      case 'German':
        return const Locale('de');
      case 'Chinese':
        return const Locale('zh');
      case 'Japanese':
        return const Locale('ja');
      case 'Russian':
        return const Locale('ru');
      case 'Arabic':
        return const Locale('ar');
      case 'Portuguese':
        return const Locale('pt');
      case 'English':
      default:
        return const Locale('en');
    }
  }

  static String getLanguageFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'Hindi';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'zh':
        return 'Chinese';
      case 'ja':
        return 'Japanese';
      case 'ru':
        return 'Russian';
      case 'ar':
        return 'Arabic';
      case 'pt':
        return 'Portuguese';
      case 'en':
      default:
        return 'English';
    }
  }
}
