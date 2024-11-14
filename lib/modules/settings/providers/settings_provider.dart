import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/common/result.dart';
import '../../provider_setup/providers.dart';
import '../../logging/providers/i_logging_provider.dart';
import '../services/iuser_settings_service.dart';
import '../services/app_settings_service.dart';

class SettingsState {
  final String currentLanguage;
  final bool notificationsEnabled;
  final bool accessibilityFeaturesEnabled;
  final Locale? currentLocale;

  SettingsState({
    required this.currentLanguage,
    required this.notificationsEnabled,
    required this.accessibilityFeaturesEnabled,
    this.currentLocale,
  });

  SettingsState copyWith({
    String? currentLanguage,
    bool? notificationsEnabled,
    bool? accessibilityFeaturesEnabled,
    Locale? currentLocale,
  }) {
    return SettingsState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      accessibilityFeaturesEnabled:
          accessibilityFeaturesEnabled ?? this.accessibilityFeaturesEnabled,
      currentLocale: currentLocale ?? this.currentLocale,
    );
  }
}

class SettingsProvider extends StateNotifier<SettingsState> {
  final ILoggingProvider logger;
  final IUserSettingsService userSettingsService;
  final AppSettingsService appSettingsService;
  final Ref ref;

  SettingsProvider({
    required this.logger,
    required this.userSettingsService,
    required this.appSettingsService,
    required this.ref,
  }) : super(SettingsState(
          currentLanguage: 'en',
          notificationsEnabled: false,
          accessibilityFeaturesEnabled: false,
        )) {
    loadSettings();
  }

  Future<Result<void>> loadSettings() async {
    try {
      final languageResult = await userSettingsService.loadLanguagePreference();
      final currentLanguage = languageResult.data ?? 'en';
      logger.logInfo('Language preference loaded: $currentLanguage');

      final notificationResult =
          await userSettingsService.loadNotificationPreference();
      final notificationsEnabled = notificationResult.data ?? false;
      logger.logInfo('Notification preference loaded: $notificationsEnabled');

      final accessibilityResult =
          await userSettingsService.loadAccessibilityPreference();
      final accessibilityFeaturesEnabled = accessibilityResult.data ?? false;
      logger.logInfo(
          'Accessibility preference loaded: $accessibilityFeaturesEnabled');

      state = state.copyWith(
        currentLanguage: currentLanguage,
        notificationsEnabled: notificationsEnabled,
        accessibilityFeaturesEnabled: accessibilityFeaturesEnabled,
      );

      // Initialize LocalizationProvider with the loaded language
      ref.read(localizationProvider.notifier).switchLanguage(currentLanguage);

      return Result.success();
    } catch (e, stackTrace) {
      return Result.failure(
          message: 'Failed to load settings: $e',
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Future<Result<void>> updateLanguage(String languageCode) async {
    try {
      state = state.copyWith(currentLanguage: languageCode);
      ref.read(localizationProvider.notifier).switchLanguage(languageCode);
      await userSettingsService.saveLanguagePreference(languageCode);
      return Result.success(
          message: "Language updated successfully to: $languageCode.");
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to update language",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Future<Result<void>> toggleNotifications(bool isEnabled) async {
    try {
      state = state.copyWith(notificationsEnabled: isEnabled);
      await userSettingsService.saveNotificationPreference(isEnabled);
      return Result.success(message: "Notifications setting updated.");
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to update notifications setting",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Future<Result<void>> toggleAccessibilityFeatures(bool isEnabled) async {
    try {
      state = state.copyWith(accessibilityFeaturesEnabled: isEnabled);
      await userSettingsService.saveAccessibilityPreference(isEnabled);
      return Result.success(message: "Accessibility features updated.");
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to update accessibility features",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Future<String> getCurrentLanguage() async {
    final languageResult = await userSettingsService.loadLanguagePreference();
    return languageResult.data ?? 'en';
  }
}
