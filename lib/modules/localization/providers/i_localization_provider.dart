import 'dart:async';
import 'dart:ui';

import '../../../enums/common_enums.dart';
import '../../../models/common/result.dart';

abstract class ILocalizationProvider {
  bool get isReady;
  bool get isLoading;
  LanguageCode get currentLanguageCode;
  Locale get currentLocale;
  Stream<void> get onLanguageChange;
  List<Locale> get supportedLocales;

  Future<bool> load();
  Future<Result<void>> initialize();
  Result<void> switchLanguage(String languageCode);
  String translate(String key, {Map<String, String>? params});
  String getString(String key, {Map<String, String>? params});
  void setCurrentLanguage(LanguageCode languageCode);
  List<Locale> getAvailableLanguages();
  Result<List<Locale>> getSupportedLocales();
  Result<void> loadLocalizedStrings(String locale, Map<String, String> localizedStrings);
}