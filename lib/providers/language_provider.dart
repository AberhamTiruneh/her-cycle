import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale;

  LanguageProvider({String initialLanguage = 'en'})
      : _locale = Locale(initialLanguage);

  Locale get locale => _locale;

  String get currentLanguage => _locale.languageCode;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language') ?? 'en';
    _locale = Locale(saved);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }

  static final List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'en',
      englishName: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    LanguageOption(
      code: 'am',
      englishName: 'Amharic',
      nativeName: 'አማርኛ',
      flag: '🇪🇹',
    ),
    LanguageOption(
      code: 'fr',
      englishName: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    LanguageOption(
      code: 'es',
      englishName: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    LanguageOption(
      code: 'ar',
      englishName: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
    LanguageOption(
      code: 'pt',
      englishName: 'Portuguese',
      nativeName: 'Português',
      flag: '🇧🇷',
    ),
    LanguageOption(
      code: 'sw',
      englishName: 'Swahili',
      nativeName: 'Kiswahili',
      flag: '🇰🇪',
    ),
    LanguageOption(
      code: 'hi',
      englishName: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'zh',
      englishName: 'Chinese',
      nativeName: '中文',
      flag: '🇨🇳',
    ),
  ];
}

class LanguageOption {
  final String code;
  final String englishName;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.flag,
  });
}
