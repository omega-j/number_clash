import 'package:beta_app/models/common/result.dart';
import 'package:beta_app/modules/localization/providers/localization_provider.dart';
import 'package:beta_app/modules/settings/providers/settings_provider.dart';
import 'package:beta_app/modules/provider_setup/providers.dart';
import 'package:beta_app/modules/settings/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mocks.mocks.dart';
import '../mocks/mock_app_settings_service.mocks.dart';
import '../mocks/mock_localization_provider.mocks.dart';

void main() async {
  // Initialize Firebase for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  late MockILoggingProvider mockLogger;
  late MockIUserSettingsService mockUserSettingsService;
  late MockLocalizationProvider mockLocalizationProvider;
  late MockAppSettingsService mockAppSettingsService;
  late ProviderContainer container;

  setUp(() {
    mockLogger = MockILoggingProvider();
    mockUserSettingsService = MockIUserSettingsService();
    mockLocalizationProvider = MockLocalizationProvider();
    mockAppSettingsService = MockAppSettingsService();

    container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith(
          (ref) => SettingsProvider(
            logger: mockLogger,
            userSettingsService: mockUserSettingsService,
            appSettingsService: mockAppSettingsService,
            ref: ref,
          ),
        ),
        localizationProvider.overrideWith(
          (ref) => mockLocalizationProvider,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state of SettingsProvider', () {
    final settings = container.read(settingsProvider);

    expect(settings.currentLanguage, 'en');
    expect(settings.notificationsEnabled, false);
    expect(settings.accessibilityFeaturesEnabled, false);
  });

  test('Updates language in LocalizationProvider', () async {
    final settings = container.read(settingsProvider.notifier);

    when(mockLocalizationProvider.switchLanguage('es'))
        .thenAnswer((_) async => Result<void>.success());

    await settings.updateLanguage('es');

    verify(mockLocalizationProvider.switchLanguage('es')).called(1);
    expect(container.read(settingsProvider).currentLanguage, 'es');
  });

  test('Toggles notifications setting', () async {
    final settings = container.read(settingsProvider.notifier);

    await settings.toggleNotifications(true);

    expect(container.read(settingsProvider).notificationsEnabled, true);
    verify(mockUserSettingsService.saveNotificationPreference(true)).called(1);
  });

  test('Toggles accessibility features setting', () async {
    final settings = container.read(settingsProvider.notifier);

    await settings.toggleAccessibilityFeatures(true);

    expect(container.read(settingsProvider).accessibilityFeaturesEnabled, true);
    verify(mockUserSettingsService.saveAccessibilityPreference(true)).called(1);
  });

  test('Loads language preference on initialization', () async {
    when(mockUserSettingsService.loadLanguagePreference())
        .thenAnswer((_) async => Result.success(data: 'fr'));

    await container.read(settingsProvider.notifier).loadSettings();

    expect(container.read(settingsProvider).currentLanguage, 'fr');
  });

  test('Handles error when updating language', () async {
    when(mockUserSettingsService.saveLanguagePreference(any))
        .thenThrow(Exception('Error saving language'));

    final result =
        await container.read(settingsProvider.notifier).updateLanguage('es');

    expect(result.isFailure, true);
    verify(mockLogger.logError(any)).called(1);
  });

  test(
      'SettingsProvider should call switchLanguage on LocalizationProvider when updating language',
      () async {
    const newLanguageCode = 'es';

    when(mockLocalizationProvider.switchLanguage(newLanguageCode))
        .thenAnswer((_) async => Result<void>.success());

    await container
        .read(settingsProvider.notifier)
        .updateLanguage(newLanguageCode);

    verify(mockLocalizationProvider.switchLanguage(newLanguageCode)).called(1);
  });

  testWidgets('Selecting a new language updates text in real-time',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
            (ref) => SettingsProvider(
              logger: mockLogger,
              userSettingsService: mockUserSettingsService,
              appSettingsService: mockAppSettingsService,
              ref: ref,
            ),
          ),
          localizationProvider.overrideWith(
            (ref) => mockLocalizationProvider,
          ),
        ],
        child: MaterialApp(home: SettingsPage()),
      ),
    );

    // Open language dropdown and select a language
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ES').last); // Assuming 'ES' is Spanish
    await tester.pumpAndSettle();

    // Check if UI reflects the language change
    expect(find.text('Configuración'), findsOneWidget); // 'Settings' in Spanish
  });

  test('Switches language successfully and updates state', () async {
    const newLanguageCode = 'es';
    when(mockLocalizationProvider.switchLanguage(newLanguageCode))
        .thenAnswer((_) async => Result<void>.success());

    final result = await container
        .read(settingsProvider.notifier)
        .updateLanguage(newLanguageCode);

    expect(result.isSuccessful, isTrue);
    expect(container.read(settingsProvider).currentLanguage, newLanguageCode);
    verify(mockLocalizationProvider.switchLanguage(newLanguageCode)).called(1);
  });
}