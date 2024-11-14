class AssetPaths {
  static const String localization = 'assets/translations';
  
  static const String themes = 'assets/themes';
  
  static const String availableLanguagesManifest =
      'assets/translations/localization_manifest.json';
  static const String defaultLogoPath = 'assets/images/app_logo.png';

  static String localizationFile(String language) =>
      '$localization/$language.json';

  static String themeFile() => '$themes/default/theme_default_v1.0.json';
}
