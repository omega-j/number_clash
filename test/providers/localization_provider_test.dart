import 'dart:ui';
import 'package:beta_app/models/common/result.dart';
import 'package:beta_app/modules/provider_setup/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beta_app/modules/localization/providers/localization_provider.dart';
import 'package:beta_app/modules/input_output/providers/input_output_provider.dart';
import 'package:beta_app/modules/logging/providers/i_logging_provider.dart';
import '../mocks.mocks.dart';
import '../mocks/mock_input_output_provider.mocks.dart';
import '../mocks/mock_localization_provider.dart';
import '../mocks/mock_app_settings_service.mocks.dart';

void main() {
  late ProviderContainer container;
  late LocalizationProvider localizationProvider;
  late MockILoggingProvider mockLogger;
  late MockInputOutputProvider mockIoProvider;
  late MockAppSettingsService mockAppSettingsService;

  setUp(() {
    container = ProviderContainer(); // Initialize ProviderScope for Riverpod
    mockLogger = MockILoggingProvider();
    mockIoProvider = MockInputOutputProvider();
    mockAppSettingsService = MockAppSettingsService();

    // Create the localization provider with mocked dependencies
    localizationProvider = LocalizationProvider(
        logger: mockLogger,
        ioProvider: mockIoProvider,
        appSettingsService: mockAppSettingsService);
  });

  tearDown(() {
    container.dispose(); // Dispose ProviderScope after tests
  });

  group('LocalizationProvider', () {
    test('initializes supported locales successfully', () async {
      // Arrange
      when(mockIoProvider.loadSupportedLocales()).thenAnswer(
          (_) async => Result.success(data: [Locale('en'), Locale('es')]));

      // Act
      final result = await localizationProvider.initialize();

      // Assert
      expect(result.isSuccessful, isTrue);
      expect(localizationProvider.supportedLocales, contains(Locale('en')));
      verify(mockLogger.logInfo(any)).called(greaterThanOrEqualTo(1));
    });

    test('switches language successfully', () async {
      // Arrange
      final languageCode = 'es';
      when(mockIoProvider.loadLocalizationFile(languageCode))
          .thenAnswer((_) async => Result.success(data: {'hello': 'Hola'}));

      // Act
      final result = await localizationProvider.switchLanguage(languageCode);

      // Assert
      expect(result.isSuccessful, isTrue);
      expect(localizationProvider.currentLanguageCode.value, languageCode);
      verify(mockLogger.logInfo(contains('Switched language to es') as String?))
          .called(1);
    });

    test('fails to switch to an unsupported language', () async {
      // Arrange
      final unsupportedLanguageCode = 'de';
      when(mockIoProvider.loadLocalizationFile(unsupportedLanguageCode))
          .thenAnswer(
              (_) async => Result.failure(message: 'Language not supported'));

      // Act
      final result =
          await localizationProvider.switchLanguage(unsupportedLanguageCode);

      // Assert
      expect(result.isSuccessful, isFalse);
      expect(result.message, contains('Language not supported'));
      verify(mockLogger.logError(contains('Language not supported') as String?))
          .called(1);
    });

    test('translates a key successfully', () {
      // Arrange
      localizationProvider.loadLocalizedStrings('en', {'hello': 'Hello'});

      // Act
      final result = localizationProvider.translate('hello');

      // Assert
      expect(result, 'Hello');
    });

    test('returns key when translation is missing', () {
      // Arrange
      localizationProvider.loadLocalizedStrings('en', {'hello': 'Hello'});

      // Act
      final result = localizationProvider.translate('missing_key');

      // Assert
      expect(result, 'missing_key');
      verify(mockLogger.logError(
              contains('Unable to find translation for key') as String?))
          .called(1);
    });

    test('handles initialization error gracefully', () async {
      // Arrange
      when(mockIoProvider.loadSupportedLocales())
          .thenThrow(Exception('File error'));

      // Act
      final result = await localizationProvider.initialize();

      // Assert
      expect(result.isSuccessful, isFalse);
      verify(mockLogger.logError(
              contains('Failed to initialize localization') as String?))
          .called(1);
    });

    test('Handles error when switching to an unsupported language', () async {
      // Arrange
      final unsupportedLanguageCode = 'de';
      when(mockIoProvider.loadLocalizationFile(unsupportedLanguageCode))
          .thenAnswer(
              (_) async => Result.failure(message: 'Language not supported'));

      // Act
      final result =
          await localizationProvider.switchLanguage(unsupportedLanguageCode);

      // Assert
      expect(result.isSuccessful, isFalse);
      expect(result.message, contains('Language not supported'));
      verify(mockLogger.logError(argThat(contains('Language not supported'))))
          .called(1);
    });
  });
}
