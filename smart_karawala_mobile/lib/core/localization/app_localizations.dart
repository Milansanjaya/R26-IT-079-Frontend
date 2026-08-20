import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'translations/en.dart';
import 'translations/si.dart';
import 'translations/ta.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('si', ''),
    Locale('ta', ''),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late final Map<String, String> _localizedStrings = _loadLocalizedStrings();

  Map<String, String> _loadLocalizedStrings() {
    switch (locale.languageCode) {
      case 'si':
        return siTranslations;
      case 'ta':
        return taTranslations;
      case 'en':
      default:
        return enTranslations;
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String value = _localizedStrings[key] ?? enTranslations[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramVal) {
        value = value.replaceAll('{$paramKey}', paramVal);
      });
    }
    return value;
  }

  String get currentLanguageCode => locale.languageCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'si', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    final localizations = AppLocalizations.of(this);
    if (localizations != null) {
      return localizations.translate(key, params: params);
    }
    return enTranslations[key] ?? key;
  }

  bool get isSinhala =>
      AppLocalizations.of(this)?.currentLanguageCode == 'si';

  bool get isTamil =>
      AppLocalizations.of(this)?.currentLanguageCode == 'ta';

  bool get isEnglish =>
      AppLocalizations.of(this)?.currentLanguageCode == 'en';
}
