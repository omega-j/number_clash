import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../enums/common_enums.dart';
import '../../../models/common/result.dart';
import '../../input_output/providers/i_input_output_provider.dart';
import '../../logging/providers/i_logging_provider.dart';
import 'i_localization_provider.dart';
import '../../settings/services/app_settings_service.dart';

// LocalizationState model for managing locale and loading status
class LocalizationState {
  final Locale locale;
  final bool isLoading;

  LocalizationState({
    required this.locale,
    this.isLoading = false,
  });

  LocalizationState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocalizationState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocalizationProvider extends StateNotifier<LocalizationState>
    implements ILocalizationProvider {
  static final LocalizationProvider _instance = LocalizationProvider._internal(
    logger: null,
    ioProvider: null,
    appSettingsService: null,
  );

  ILoggingProvider? logger;
  IInputOutputProvider? ioProvider;
  AppSettingsService? appSettingsService;

  final Map<String, Map<String, String>> _translations = {};
  final StreamController<void> _languageChangeController =
      StreamController.broadcast();

  bool _isReady = false;
  LanguageCode _currentLanguageCode = LanguageCode.english;
  List<Locale> _supportedLocales = [];

  LocalizationProvider._internal({
    required this.logger,
    required this.ioProvider,
    required this.appSettingsService,
  }) : super(LocalizationState(locale: Locale('en')));

  factory LocalizationProvider({
    required ILoggingProvider logger,
    required IInputOutputProvider ioProvider,
    required AppSettingsService appSettingsService,
  }) {
    if (_instance.logger == null && _instance.ioProvider == null && _instance.appSettingsService == null) {
      _instance.logger = logger;
      _instance.ioProvider = ioProvider;
      _instance.appSettingsService = appSettingsService;
      _instance.initialize();
    }
    return _instance;
  }

  @override
  bool get isReady => _isReady;

  @override
  LanguageCode get currentLanguageCode => _currentLanguageCode;

  @override
  Locale get currentLocale => state.locale;

  @override
  bool get isLoading => state.isLoading;

  @override
  Stream<void> get onLanguageChange => _languageChangeController.stream;

  @override
  List<Locale> get supportedLocales => List.unmodifiable(_supportedLocales);

  @override
  Future<bool> load() async {
    final initializationResult = await initialize();
    return initializationResult.isSuccessful;
  }

  @override
  Future<Result<void>> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      _currentLanguageCode = await _loadInitialLanguage();
      final localesResult = await ioProvider!.loadSupportedLocales();

      if (localesResult.isSuccessfulAndDataIsNotNull) {
        _supportedLocales = localesResult.data!;
        await _loadAllTranslations();

        _isReady = _supportedLocales
            .every((locale) => _translations.containsKey(locale.languageCode));
        _applyFallbackIfNeeded();
        notifyLanguageChange();
        return Result.success();
      } else {
        return Result.failure(message: "Failed to load supported locales");
      }
    } catch (e, stackTrace) {
      return Result.failure(
          message: 'Failed to initialize localization',
          exception: e,
          stackTrace: stackTrace);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<LanguageCode> _loadInitialLanguage() async {
    final savedLanguage = await appSettingsService!.loadLanguagePreference();
    return LanguageCode.fromString(savedLanguage.data!) ??
        _getDeviceLanguageCode();
  }

  Future<void> _loadAllTranslations() async {
    for (Locale locale in _supportedLocales) {
      final languageCode = locale.languageCode;
      final fileResult = await ioProvider!.loadLocalizationFile(languageCode);

      if (fileResult.isSuccessfulAndDataIsNotNull) {
        _translations[languageCode] = fileResult.data!;
        logger!.logInfo(
            "Loaded ${fileResult.data!.length} translations for $languageCode");
      } else {
        logger!.logWarning("Failed to load translations for $languageCode");
      }
    }
  }

  void _applyFallbackIfNeeded() {
    if (!_translations.containsKey(_currentLanguageCode.value)) {
      _currentLanguageCode = LanguageCode.english;
      logger!.logWarning(
          "Fallback to English due to missing localization for: ${_currentLanguageCode.value}");
    }
  }

  @override
  Result<void> switchLanguage(String languageCode) {
    try {
      if (!_translations.containsKey(languageCode)) {
        return Result.failure(
            message: "Language $languageCode not supported. Using fallback.");
      } else {
        _currentLanguageCode =
            LanguageCode.fromString(languageCode) ?? LanguageCode.english;
        _applyFallbackIfNeeded();
        setLanguage(languageCode);
        notifyLanguageChange();
        return Result.success();
      }
    } catch (e) {
      return Result.failure(
          message:
              "Failed to set the language setting for Language: $languageCode",
          exception: e);
    }
  }

  @override
  String translate(String key, {Map<String, String>? params}) {
    String result = _translations[_currentLanguageCode.value]?[key] ??
        _translations[LanguageCode.english.value]?[key] ??
        key;

    if (params != null) {
      params.forEach((paramKey, value) {
        result = result.replaceAll('{$paramKey}', value);
      });
    }
    return result;
  }

  @override
  String getString(String key, {Map<String, String>? params}) =>
      translate(key, params: params);

  LanguageCode _getDeviceLanguageCode() {
    final deviceLocale = PlatformDispatcher.instance.locales.first;
    return LanguageCode.values.firstWhere(
      (locale) => locale.value == deviceLocale.languageCode,
      orElse: () => LanguageCode.english,
    );
  }

  @override
  void setCurrentLanguage(LanguageCode languageCode) {
    _currentLanguageCode = languageCode;
    _applyFallbackIfNeeded();
    setLanguage(languageCode.value);
  }

  @override
  List<Locale> getAvailableLanguages() {
    return _supportedLocales;
  }

  @override
  Result<List<Locale>> getSupportedLocales() {
    return Result.success(data: _supportedLocales);
  }

  @override
  Result<void> loadLocalizedStrings(
      String locale, Map<String, String> localizedStrings) {
    try {
      _translations[locale] = localizedStrings;
      return Result.success();
    } catch (e) {
      return Result.failure(
          message: 'Error loading localized strings for locale $locale',
          exception: e);
    }
  }

  void setLanguage(String languageCode) {
    state = state.copyWith(locale: Locale(languageCode));
  }

  void notifyLanguageChange() {
    if (!_languageChangeController.isClosed) {
      _languageChangeController.add(null);
    }
  }

  @override
  void dispose() {
    _languageChangeController.close();
    super.dispose();
  }
}