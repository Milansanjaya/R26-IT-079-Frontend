import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageModel {
  final String code;
  final String englishName;
  final String nativeName;
  final String subLabel;
  final Locale locale;

  const LanguageModel({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.subLabel,
    required this.locale,
  });
}

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language_code';

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(
      code: 'en',
      englishName: 'English',
      nativeName: 'English',
      subLabel: 'Default (EN)',
      locale: Locale('en', ''),
    ),
    LanguageModel(
      code: 'si',
      englishName: 'Sinhala',
      nativeName: 'සිංහල',
      subLabel: 'Sri Lanka (SI)',
      locale: Locale('si', ''),
    ),
    LanguageModel(
      code: 'ta',
      englishName: 'Tamil',
      nativeName: 'தமிழ்',
      subLabel: 'Sri Lanka / India (TA)',
      locale: Locale('ta', ''),
    ),
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('si', ''),
    Locale('ta', ''),
  ];

  Locale _currentLocale = const Locale('en', '');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isInitialized => _isInitialized;

  LanguageModel get currentLanguage => supportedLanguages.firstWhere(
        (lang) => lang.code == _currentLocale.languageCode,
        orElse: () => supportedLanguages.first,
      );

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);

      if (savedCode != null &&
          supportedLanguages.any((lang) => lang.code == savedCode)) {
        _currentLocale = Locale(savedCode, '');
      } else {
        _currentLocale = const Locale('en', '');
      }
    } catch (e) {
      _currentLocale = const Locale('en', '');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale newLocale) async {
    if (_currentLocale.languageCode == newLocale.languageCode) return;

    _currentLocale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (e) {
      debugPrint("Error saving language preference: $e");
    }
  }

  Future<void> changeLanguageByCode(String languageCode) async {
    final match = supportedLanguages.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => supportedLanguages.first,
    );
    await changeLanguage(match.locale);
  }
}
